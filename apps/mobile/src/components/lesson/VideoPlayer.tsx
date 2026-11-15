/* eslint-disable react-hooks/immutability, react-hooks/set-state-in-effect -- imperative player API; component opts out via 'use no memo' */
import { useEvent } from 'expo';
import { useVideoPlayer, VideoView } from 'expo-video';
import { Captions, Gauge, Maximize, Pause, Play, RotateCcw, RotateCw, Settings2 } from 'lucide-react-native';
import { useCallback, useEffect, useRef, useState } from 'react';
import { ActivityIndicator, Pressable, StyleSheet, View, type LayoutChangeEvent } from 'react-native';
import { Gesture, GestureDetector } from 'react-native-gesture-handler';
import Animated, { FadeIn, FadeOut, runOnJS } from 'react-native-reanimated';

import { Sheet } from '@/components/ui/Sheet';
import { Text } from '@/components/ui/Text';
import type { LessonVideo } from '@/data/types';
import { haptics } from '@/lib/haptics';
import { useI18n } from '@/i18n';
import { usePreferences } from '@/stores/preferences';
import { useTheme } from '@/theme/ThemeProvider';

const SPEEDS = [0.75, 1, 1.25, 1.5, 1.75, 2];

interface Cue {
  start: number;
  end: number;
  text: string;
}

function parseVtt(vtt: string): Cue[] {
  const toSec = (s: string) => {
    const p = s.trim().split(':').map(parseFloat);
    return p.length === 3 ? p[0] * 3600 + p[1] * 60 + p[2] : p[0] * 60 + p[1];
  };
  return vtt
    .replace(/\r/g, '')
    .split('\n\n')
    .map((block) => {
      const lines = block.split('\n');
      const i = lines.findIndex((l) => l.includes('-->'));
      if (i < 0) return null;
      const [a, b] = lines[i].split('-->');
      return { start: toSec(a), end: toSec(b.split(' ')[1] ?? b), text: lines.slice(i + 1).join('\n').replace(/<[^>]+>/g, '') };
    })
    .filter((c): c is Cue => !!c);
}

const fmt = (s: number) => {
  const m = Math.floor(s / 60);
  const sec = Math.floor(s % 60);
  return `${m}:${String(sec).padStart(2, '0')}`;
};

export interface VideoPlayerProps {
  video: LessonVideo;
  startAt?: number;
  title?: string;
  onHeartbeat?: (positionSeconds: number, secondsSpent: number) => void;
  onNearlyComplete?: () => void;
}

export function VideoPlayer({ video, startAt = 0, title, onHeartbeat, onNearlyComplete }: VideoPlayerProps) {
  // expo-video is driven imperatively (player.currentTime = …, player.playbackRate = …),
  // which the React Compiler cannot model; keep this component un-memoised.
  'use no memo';
  const t = useTheme();
  const { t: tr } = useI18n();
  const prefs = usePreferences();
  const [sourceIndex, setSourceIndex] = useState(0);
  const source = video.sources[sourceIndex];
  const viewRef = useRef<VideoView>(null);
  const [controls, setControls] = useState(true);
  const [sheet, setSheet] = useState<null | 'speed' | 'quality' | 'captions'>(null);
  const [captionLang, setCaptionLang] = useState<string | null>(prefs.captionsEnabled ? video.captions[0]?.language ?? null : null);
  const [cues, setCues] = useState<Cue[]>([]);
  const [trackWidth, setTrackWidth] = useState(1);
  const [scrub, setScrub] = useState<number | null>(null);
  const resumeRef = useRef(startAt);
  const spentRef = useRef(0);
  const completedRef = useRef(false);

  const player = useVideoPlayer({ uri: source.uri, metadata: { title: title ?? '' } }, (p) => {
    p.timeUpdateEventInterval = 0.5;
    p.playbackRate = prefs.playbackRate;
    p.preservesPitch = true;
    p.keepScreenOnWhilePlaying = true;
  });

  const { status, error } = useEvent(player, 'statusChange', { status: player.status });
  const { isPlaying } = useEvent(player, 'playingChange', { isPlaying: player.playing });
  const { currentTime } = useEvent(player, 'timeUpdate', { currentTime: player.currentTime, currentLiveTimestamp: null, currentOffsetFromLive: null, bufferedPosition: 0 });
  const duration = player.duration || video.duration_seconds || 0;

  // Resume where the learner left off once the media is ready.
  useEffect(() => {
    if (status === 'readyToPlay' && resumeRef.current > 0) {
      player.currentTime = Math.min(resumeRef.current, Math.max(0, duration - 5));
      resumeRef.current = 0;
    }
  }, [status, player, duration]);

  // Watch-time accounting + heartbeat every 15 seconds of playback.
  useEffect(() => {
    if (!isPlaying) return;
    const id = setInterval(() => {
      spentRef.current += 1;
      if (spentRef.current >= 15) {
        onHeartbeat?.(Math.floor(player.currentTime), spentRef.current);
        spentRef.current = 0;
      }
    }, 1000);
    return () => clearInterval(id);
  }, [isPlaying, player, onHeartbeat]);

  useEffect(
    () => () => {
      if (spentRef.current > 0) onHeartbeat?.(Math.floor(player.currentTime), spentRef.current);
    },
    [], // eslint-disable-line react-hooks/exhaustive-deps
  );

  useEffect(() => {
    if (!completedRef.current && duration > 0 && currentTime / duration >= 0.9) {
      completedRef.current = true;
      onNearlyComplete?.();
    }
  }, [currentTime, duration, onNearlyComplete]);

  // Auto-hide controls while playing.
  useEffect(() => {
    if (!controls || !isPlaying || sheet) return;
    const id = setTimeout(() => setControls(false), 3200);
    return () => clearTimeout(id);
  }, [controls, isPlaying, sheet, currentTime]);

  // Load sidecar WebVTT captions.
  useEffect(() => {
    const track = video.captions.find((c) => c.language === captionLang);
    if (!track) return setCues([]);
    let cancelled = false;
    fetch(track.uri)
      .then((r) => r.text())
      .then((txt) => !cancelled && setCues(parseVtt(txt)))
      .catch(() => setCues([]));
    return () => {
      cancelled = true;
    };
  }, [captionLang, video.captions]);

  const togglePlay = useCallback(() => {
    haptics.tap();
    if (player.playing) player.pause();
    else {
      if (duration && player.currentTime >= duration - 0.5) player.currentTime = 0;
      player.play();
    }
    setControls(true);
  }, [player, duration]);

  const seekTo = useCallback((ratio: number) => {
    player.currentTime = Math.max(0, Math.min(1, ratio)) * (player.duration || 0);
    setScrub(null);
  }, [player]);

  const scrubGesture = Gesture.Pan()
    .onBegin((e) => runOnJS(setScrub)(Math.max(0, Math.min(1, e.x / trackWidth))))
    .onUpdate((e) => runOnJS(setScrub)(Math.max(0, Math.min(1, e.x / trackWidth))))
    .onEnd((e) => runOnJS(seekTo)(e.x / trackWidth));
  const tapGesture = Gesture.Tap().onEnd((e) => runOnJS(seekTo)(e.x / trackWidth));

  const progress = scrub ?? (duration ? currentTime / duration : 0);
  const cue = cues.find((c) => currentTime >= c.start && currentTime <= c.end);

  const switchSource = async (i: number) => {
    const pos = player.currentTime;
    setSourceIndex(i);
    await player.replaceAsync({ uri: video.sources[i].uri });
    player.currentTime = pos;
    player.play();
  };

  return (
    <View style={[styles.wrap, { borderRadius: t.radii.lg }]}>
      <VideoView ref={viewRef} player={player} style={StyleSheet.absoluteFill} nativeControls={false} contentFit="contain" allowsPictureInPicture fullscreenOptions={{ enable: true }} />
      {cue && (
        <View pointerEvents="none" style={styles.cueWrap}>
          <Text variant="callout" color="#FFFFFF" align="center" style={styles.cue}>
            {cue.text}
          </Text>
        </View>
      )}
      <Pressable style={StyleSheet.absoluteFill} onPress={() => setControls((c) => !c)} accessibilityLabel={isPlaying ? 'Hide controls' : 'Show controls'} />

      {(status === 'loading' || status === 'idle') && !error && (
        <View style={styles.center} pointerEvents="none">
          <ActivityIndicator color="#FFFFFF" />
        </View>
      )}
      {status === 'error' && (
        <View style={[styles.center, { padding: 24 }]}>
          <Text variant="callout" color="#FFFFFF" align="center">
            {tr('lesson.videoError')}
          </Text>
        </View>
      )}

      {controls && status !== 'error' && (
        <Animated.View entering={FadeIn.duration(160)} exiting={FadeOut.duration(220)} style={[StyleSheet.absoluteFill, styles.overlay]} pointerEvents="box-none">
          <View style={styles.topRow}>
            <OverlayButton icon={Gauge} label={`${tr('lesson.speed')}: ${player.playbackRate}×`} text={`${player.playbackRate}×`} onPress={() => setSheet('speed')} />
            {video.captions.length > 0 && <OverlayButton icon={Captions} label={tr('lesson.captions')} active={!!captionLang} onPress={() => setSheet('captions')} />}
            {video.sources.length > 1 && <OverlayButton icon={Settings2} label={tr('lesson.quality')} onPress={() => setSheet('quality')} />}
            <OverlayButton icon={Maximize} label={tr('lesson.fullscreen')} onPress={() => viewRef.current?.enterFullscreen()} />
          </View>
          <View style={styles.middleRow} pointerEvents="box-none">
            <OverlayButton icon={RotateCcw} label="-10s" size={44} onPress={() => player.seekBy(-10)} />
            <Pressable onPress={togglePlay} accessibilityRole="button" accessibilityLabel={isPlaying ? 'Pause' : 'Play'} style={styles.playBig}>
              {isPlaying ? <Pause size={28} color="#0B0C10" fill="#0B0C10" /> : <Play size={28} color="#0B0C10" fill="#0B0C10" style={{ marginLeft: 3 }} />}
            </Pressable>
            <OverlayButton icon={RotateCw} label="+10s" size={44} onPress={() => player.seekBy(10)} />
          </View>
          <View style={styles.bottomRow}>
            <Text variant="caption" color="#FFFFFF" style={styles.time}>
              {fmt(scrub !== null ? scrub * duration : currentTime)}
            </Text>
            <GestureDetector gesture={Gesture.Exclusive(scrubGesture, tapGesture)}>
              <View
                style={styles.track}
                onLayout={(e: LayoutChangeEvent) => setTrackWidth(e.nativeEvent.layout.width || 1)}
                accessibilityRole="adjustable"
                accessibilityLabel="Seek"
                accessibilityValue={{ min: 0, max: Math.round(duration), now: Math.round(currentTime) }}>
                <View style={styles.trackBg} />
                <View style={[styles.trackFill, { width: `${progress * 100}%`, backgroundColor: t.colors.accent }]} />
                <View style={[styles.thumb, { left: `${progress * 100}%`, backgroundColor: t.colors.accent }]} />
              </View>
            </GestureDetector>
            <Text variant="caption" color="#FFFFFF" style={styles.time}>
              {fmt(duration)}
            </Text>
          </View>
        </Animated.View>
      )}

      <Sheet visible={sheet === 'speed'} onClose={() => setSheet(null)} title={tr('lesson.speed')}>
        <OptionList
          options={SPEEDS.map((s) => ({ key: String(s), label: `${s}×` }))}
          selected={String(player.playbackRate)}
          onSelect={(k) => {
            player.playbackRate = Number(k);
            prefs.set({ playbackRate: Number(k) });
            setSheet(null);
          }}
        />
      </Sheet>
      <Sheet visible={sheet === 'quality'} onClose={() => setSheet(null)} title={tr('lesson.quality')}>
        <OptionList
          options={video.sources.map((s, i) => ({ key: String(i), label: s.quality ?? tr('lesson.auto') }))}
          selected={String(sourceIndex)}
          onSelect={(k) => {
            setSheet(null);
            void switchSource(Number(k));
          }}
        />
      </Sheet>
      <Sheet visible={sheet === 'captions'} onClose={() => setSheet(null)} title={tr('lesson.captions')}>
        <OptionList
          options={[{ key: 'off', label: tr('lesson.off') }, ...video.captions.map((c) => ({ key: c.language, label: c.label }))]}
          selected={captionLang ?? 'off'}
          onSelect={(k) => {
            setCaptionLang(k === 'off' ? null : k);
            setSheet(null);
          }}
        />
      </Sheet>
    </View>
  );
}

function OverlayButton({ icon: Icon, label, onPress, text, size = 36, active }: { icon: typeof Play; label: string; onPress: () => void; text?: string; size?: number; active?: boolean }) {
  return (
    <Pressable onPress={onPress} accessibilityRole="button" accessibilityLabel={label} hitSlop={8} style={[styles.overlayBtn, { height: size, minWidth: size, borderRadius: size / 2 }, active && { backgroundColor: 'rgba(232,192,122,0.35)' }]}>
      <Icon size={size * 0.46} color="#FFFFFF" />
      {text && (
        <Text variant="caption" color="#FFFFFF">
          {text}
        </Text>
      )}
    </Pressable>
  );
}

export function OptionList({ options, selected, onSelect }: { options: { key: string; label: string; description?: string }[]; selected: string; onSelect: (k: string) => void }) {
  const t = useTheme();
  return (
    <View style={{ paddingHorizontal: 16, gap: 6 }}>
      {options.map((o) => {
        const isSel = o.key === selected;
        return (
          <Pressable
            key={o.key}
            onPress={() => onSelect(o.key)}
            accessibilityRole="radio"
            accessibilityState={{ selected: isSel }}
            style={[styles.option, { backgroundColor: isSel ? t.colors.accentSoft : t.colors.surface, borderRadius: t.radii.md, borderColor: isSel ? t.colors.accent : t.colors.border }]}>
            <Text variant="bodyStrong" tone={isSel ? 'accent' : 'primary'}>
              {o.label}
            </Text>
            {o.description ? (
              <Text variant="footnote" tone="secondary">
                {o.description}
              </Text>
            ) : null}
          </Pressable>
        );
      })}
    </View>
  );
}

const styles = StyleSheet.create({
  wrap: { width: '100%', aspectRatio: 16 / 9, backgroundColor: '#000', overflow: 'hidden' },
  overlay: { backgroundColor: 'rgba(0,0,0,0.38)', justifyContent: 'space-between', padding: 10 },
  center: { position: 'absolute', top: 0, left: 0, right: 0, bottom: 0, alignItems: 'center', justifyContent: 'center' },
  topRow: { flexDirection: 'row', justifyContent: 'flex-end', gap: 8 },
  middleRow: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 28 },
  bottomRow: { flexDirection: 'row', alignItems: 'center', gap: 10 },
  time: { width: 44, textAlign: 'center', fontVariant: ['tabular-nums'] },
  track: { flex: 1, height: 28, justifyContent: 'center' },
  trackBg: { height: 4, borderRadius: 2, backgroundColor: 'rgba(255,255,255,0.3)' },
  trackFill: { position: 'absolute', left: 0, height: 4, borderRadius: 2 },
  thumb: { position: 'absolute', width: 14, height: 14, borderRadius: 7, marginLeft: -7 },
  playBig: { width: 64, height: 64, borderRadius: 32, backgroundColor: '#FFFFFF', alignItems: 'center', justifyContent: 'center' },
  overlayBtn: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 4, paddingHorizontal: 8, backgroundColor: 'rgba(0,0,0,0.45)' },
  cueWrap: { position: 'absolute', left: 16, right: 16, bottom: 48, alignItems: 'center' },
  cue: { backgroundColor: 'rgba(0,0,0,0.7)', paddingHorizontal: 10, paddingVertical: 4, borderRadius: 6, overflow: 'hidden' },
  option: { height: 52, justifyContent: 'center', paddingHorizontal: 16, borderWidth: 1 },
});
