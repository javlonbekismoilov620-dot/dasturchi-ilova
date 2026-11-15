import { router } from 'expo-router';
import { useState } from 'react';
import { ActivityIndicator, KeyboardAvoidingView, Platform, ScrollView, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

import { OptionCard } from '@/components/onboarding/OptionCard';
import { Button } from '@/components/ui/Button';
import { BackButton } from '@/components/ui/layout';
import { Chip } from '@/components/ui/primitives';
import { Text } from '@/components/ui/Text';
import { TextField } from '@/components/ui/TextField';
import { toast } from '@/components/ui/Toast';
import { iconFor } from '@/components/ui/Icon';
import { useCategories, useProfile, useUpdateProfile } from '@/data/hooks';
import type { DifficultyLevel, Profile } from '@/data/types';
import { errorMessageKey } from '@/lib/errors';
import { useI18n } from '@/i18n';
import { usePreferences } from '@/stores/preferences';
import { useTheme } from '@/theme/ThemeProvider';

const LEVELS: DifficultyLevel[] = ['zero', 'beginner', 'intermediate', 'advanced', 'professional'];

export default function EditProfile() {
  const t = useTheme();
  const profile = useProfile();
  if (!profile.data) {
    return (
      <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center', backgroundColor: t.colors.background }}>
        <ActivityIndicator color={t.colors.accent} />
      </View>
    );
  }
  return <ProfileForm key={profile.data.id} profile={profile.data} />;
}

function ProfileForm({ profile }: { profile: Profile }) {
  const t = useTheme();
  const { t: tr } = useI18n();
  const insets = useSafeAreaInsets();
  const categories = useCategories();
  const update = useUpdateProfile();
  const setPrefs = usePreferences((s) => s.set);
  const [name, setName] = useState(profile.display_name ?? '');
  const [bio, setBio] = useState(profile.bio ?? '');
  const [level, setLevel] = useState<DifficultyLevel>(profile.experience_level);
  const [interests, setInterests] = useState<string[]>(profile.interests);

  const save = async () => {
    try {
      await update.mutateAsync({ display_name: name.trim() || null, bio: bio.trim() || null, experience_level: level, interests });
      setPrefs({ interests, level });
      router.back();
    } catch (e) {
      toast.error(tr(errorMessageKey(e)));
    }
  };

  return (
    <KeyboardAvoidingView style={{ flex: 1, backgroundColor: t.colors.background }} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
      <ScrollView contentContainerStyle={{ padding: 20, paddingTop: Platform.OS === 'ios' ? 16 : insets.top + 8, paddingBottom: insets.bottom + 40, gap: 20, maxWidth: 640, width: '100%', alignSelf: 'center' }} keyboardShouldPersistTaps="handled">
        <BackButton />
        <Text variant="display">{tr('profile.editProfile')}</Text>
        <TextField label={tr('profile.displayName')} value={name} onChangeText={setName} maxLength={80} />
        <TextField label={tr('profile.bio')} value={bio} onChangeText={setBio} multiline multilineHeight={100} maxLength={500} hint={`${bio.length}/500`} />
        <Text variant="title3">{tr('onboarding.interestsTitle')}</Text>
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
          {categories.data?.map((c) => (
            <Chip key={c.id} label={c.title} icon={iconFor(c.icon)} color={c.color ?? undefined} selected={interests.includes(c.slug)} onPress={() => setInterests((x) => (x.includes(c.slug) ? x.filter((s) => s !== c.slug) : [...x, c.slug]))} />
          ))}
        </View>
        <Text variant="title3">{tr('onboarding.levelTitle')}</Text>
        <View style={{ gap: 8 }}>
          {LEVELS.map((l) => (
            <OptionCard key={l} title={tr(`levels.${l}`)} subtitle={tr(`levels.${l}Hint`)} selected={level === l} onPress={() => setLevel(l)} />
          ))}
        </View>
        <Button title={tr('common.save')} onPress={save} loading={update.isPending} size="lg" fullWidth />
      </ScrollView>
    </KeyboardAvoidingView>
  );
}
