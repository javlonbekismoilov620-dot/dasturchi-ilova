# Artificial intelligence curriculum

**Goal:** take a learner who has only heard about AI to a professional who can use AI tools responsibly, understand how models work, build applications on top of language models, train and evaluate machine-learning models, and ship AI features safely.

**Track overview**

```text
Zero          AI Fundamentals & Prompting (exists, expand)
Beginner      Practical AI for Work & Study → Prompt Engineering · AI Image & Video Generation
Intermediate  Python for Data & AI → Machine Learning Foundations · Building with LLM APIs · AI Automation
Advanced      Deep Learning · AI Agents · Deploying & Operating ML
Professional  AI Product Engineering & Responsible AI (capstone)
Expert        Specialisations: NLP and speech for Uzbek · computer vision · AI safety and evaluation
```

There are two routes through the track:
- **Users and creators** stop after the Beginner level and the automation course. No coding is required.
- **Builders** continue with Python into machine learning and LLM engineering. The Programming track's *Python for Complete Beginners* is a prerequisite for the Intermediate level.

**Principles for this track:**
- **Tool-agnostic and dated.** Lessons teach concepts that outlast products. Where a specific tool or model is shown, the lesson states the date and version, and avoids quoting capabilities or prices that change quickly.
- **Verification first.** Every course includes checking AI output against sources.
- **Privacy and law.** Learners are taught what not to share with AI tools, and the basics of personal-data rules, including Uzbekistan's Law on Personal Data.
- **Honesty about limits.** Lessons cover hallucination, bias, cost and failure modes alongside capabilities.

Total guided learning is about 300–340 hours, plus projects.

---

## AI-0 · AI Fundamentals & Prompting

**Level:** Zero · **Access:** free · **Status:** published, 3 of 9 lessons · **About 9 h**

| Module | Lessons | Practice |
| --- | --- | --- |
| 1. Understanding modern AI *(exists)* | What AI is — and what it is not ✓ · How large language models work, simply ✓ · Writing your first good prompt ✓ · Quiz ✓ | |
| 2. Using AI well *(new)* | Limits: hallucination, outdated knowledge, bias · Checking answers: sources, cross-checking, asking for uncertainty · Privacy and safety: what never to paste, school and work rules | Verify five AI answers and grade them |
| 3. AI in everyday life *(new)* | Studying with AI without cheating yourself · AI for writing, translation (including Uzbek and Russian) and planning | Study plan with verified explanations |
| Final | Project: *A short explainer on a topic of your choice*, written with AI help, with every fact verified and a note on how AI was used · Final assessment | Rubric: accuracy, sources, disclosure |

## AI-1 · Practical AI for Work & Study

**Level:** Beginner · **Access:** free · **About 16 h** · **Prerequisite:** AI-0

Modules:
1. Choosing a tool: chat assistants, specialised tools, local models
2. Research with sources and citation checking
3. Writing and editing with AI, keeping your own voice
4. Spreadsheets and data analysis with AI help
5. Meetings, notes and summaries
6. Translation quality and limits in Uzbek and Russian
7. Academic integrity and workplace policies
8. Personal data and confidentiality

**Project:** an AI-assisted report on a local topic with a verification log.

## AI-2 · Prompt Engineering

**Level:** Beginner → Intermediate · **About 18 h** · **Prerequisite:** AI-0

Modules:
1. Anatomy of a prompt (role, context, task, constraints, format)
2. Examples and few-shot prompting
3. Breaking problems into steps
4. Asking for structured output (tables, JSON)
5. Long documents and context limits
6. Evaluating prompts with test cases
7. Prompt injection and why it matters
8. Building a personal prompt library

**Project:** a tested prompt library (10 prompts, each with test cases and results).

## AI-3 · AI Image & Video Generation

**Level:** Beginner → Intermediate · **About 18 h** · **Prerequisite:** AI-0 (G-0 recommended)

Modules:
1. How diffusion models work, conceptually
2. Prompting for images: subject, style, composition, lighting
3. Consistency across a series
4. Editing: inpainting, outpainting, upscaling
5. Video generation basics and limits
6. Copyright, licences and platform terms
7. Disclosure and labelling
8. Deepfakes: harms, consent and law

**Project:** a consistent visual campaign (6 images) with a disclosure note, made only with permitted inputs.

## AI-4 · Python for Data & AI

**Level:** Intermediate · **About 24 h** · **Prerequisite:** P-Z3 (Python for Complete Beginners)

Modules:
1. Jupyter notebooks
2. NumPy arrays
3. pandas: loading, cleaning, grouping
4. Visualisation with Matplotlib
5. Statistics you actually need
6. Working with real (messy) datasets, including Uzbek open data where available

**Project:** an exploratory data analysis report.

## AI-5 · Machine Learning Foundations

**Level:** Intermediate · **About 30 h** · **Prerequisite:** AI-4

Modules:
1. What learning from data means
2. Train, validation and test splits
3. Linear and logistic regression
4. Decision trees and ensembles
5. Metrics: accuracy, precision and recall, ROC, regression error
6. Overfitting and regularisation
7. Feature engineering
8. Clustering and dimensionality reduction
9. scikit-learn pipelines
10. Fairness and bias checks

**Project:** an end-to-end model with an honest evaluation report.

## AI-6 · Building with LLM APIs

**Level:** Intermediate → Advanced · **About 30 h** · **Prerequisites:** P-B3 (Python: Next Steps) or P-B1 (JavaScript)

Modules:
1. How LLM APIs work: messages, tokens, context windows, cost and latency
2. System prompts and prompt templates in code
3. Structured outputs and validation
4. Tool use (function calling)
5. Retrieval-augmented generation: embeddings, chunking, vector search
6. Evaluation: test sets, graders, regression testing
7. Security: prompt injection, data leakage, keys kept on the server
8. Privacy and data retention
9. Streaming and user experience
10. Cost control and caching

**Project:** a documented Q&A assistant over a document set, with an evaluation suite and a server-side key. This mirrors how the Mahorat learning assistant is built.

## AI-7 · AI Automation

**Level:** Intermediate · **About 18 h** · **Prerequisite:** AI-2 (coding optional)

Modules:
1. Finding processes worth automating
2. No-code automation platforms
3. Connecting AI steps with triggers and actions
4. Human-in-the-loop review
5. Error handling and reliability
6. Measuring time saved
7. Security and access scopes

**Project:** automate a real workflow end to end, with a review step and a reliability log.

## AI-8 · Deep Learning

**Level:** Advanced · **About 34 h** · **Prerequisite:** AI-5

Modules:
1. Neural networks from scratch, conceptually
2. Backpropagation intuition
3. PyTorch fundamentals
4. Training loops, optimisers and regularisation
5. Convolutional networks for images
6. Sequence models to transformers
7. Transfer learning and fine-tuning
8. GPUs and compute budgets
9. Reproducibility

**Project:** fine-tune a pretrained model for a classification task, including Uzbek-language data where possible.

## AI-9 · AI Agents

**Level:** Advanced · **About 26 h** · **Prerequisite:** AI-6

Modules:
1. What an agent is (model + tools + loop)
2. Tool design
3. Planning and decomposition
4. Memory and state
5. Multi-step evaluation
6. Guardrails and permissions
7. Failure modes and recovery
8. Cost and latency budgets
9. When not to use an agent

**Project:** an agent that completes a multi-step task with tools, an evaluation harness and explicit permission boundaries.

## AI-10 · Deploying & Operating ML

**Level:** Advanced · **About 22 h** · **Prerequisites:** AI-5 or AI-6, plus IT-8 (Cloud) recommended

Modules:
1. Packaging models
2. Serving and APIs
3. Monitoring: data drift and quality
4. Versioning data and models
5. A/B tests and rollouts
6. Incident response for AI features

**Project:** deploy a model behind an API with monitoring.

## AI-P · AI Product Engineering & Responsible AI (capstone)

**Level:** Professional · **About 36 h** · **Prerequisites:** AI-6 and one of AI-8, AI-9 or AI-10

Modules:
1. Choosing problems AI should solve
2. Product design for uncertainty (confidence, fallbacks, human review)
3. Evaluation at scale and red-teaming
4. Safety, bias and accessibility
5. Privacy by design and data-protection law, including Uzbekistan's personal-data and localisation requirements
6. Governance and documentation (model cards, risk registers)
7. Communicating limits to users

**Capstone:** design, build and evaluate an AI feature with a risk assessment and an evaluation report. A mentor reviews it.

## Expert specialisations

- **NLP and speech for Uzbek:** tokenisation challenges, datasets, evaluation in Uzbek Latin and Cyrillic.
- **Computer vision.**
- **AI safety and evaluation engineering.**
