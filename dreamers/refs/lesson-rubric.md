# Lesson Rubric

Shared quality standards and structure for all AI-101 lesson content. Reference this file from any skill that generates or reviews lessons.

---

## Lesson Structure (Required Sections)

Every lesson must include these sections in this order:

### 1. Learning Objectives
- 3-5 bulleted items
- Each begins with an action verb (Define, Understand, Know, Recognize, Build, etc.)
- Specific and measurable
- Answers: "What will the reader be able to do after this lesson?"

### 2. Introduction
- 2-3 paragraphs
- Hook: why this matters to the reader
- Context: where this fits in the larger picture
- Preview: what the lesson will cover (without a dry list)

### 3. Content Sections (3-5 sections)
- Each section gets its own H2 heading
- 300-400 words per section
- One concept per section (do not overload)
- Build from simple to complex
- Use concrete examples, not abstract explanations
- Include code blocks for example prompts where relevant

### 4. Key Takeaways
- 3-5 bulleted items
- Distill the most important points
- Actionable where possible
- Different from Learning Objectives (takeaways are conclusions, objectives are goals)

### 5. Try It Yourself (Exercise)
- Clear, step-by-step instructions
- Expected outcome stated
- Practical, hands-on (not theoretical)
- Can be completed in 5-10 minutes
- Works with free-tier AI tools

### 6. Sources
- Minimum 3 verifiable URLs
- Each source must support at least one factual claim in the lesson
- Use bare URLs (no markdown links) for auto-linking
- Include source name and what it supports

---

## Content Standards

### Tone and Voice
- Plain, conversational English (like explaining to a curious friend)
- Encouraging but not condescending
- Light humor where natural (not forced)
- No academic hedging ("it is worth noting that...")
- No marketing language ("revolutionary", "game-changing")

### Reading Level
- Flesch-Kincaid grade 8 or below
- Short sentences (15-20 words average)
- Common words over jargon
- If technical term is necessary, explain immediately in plain language

### Formatting
- **Bold** for key terms (first use only)
- `code blocks` for prompts, commands, technical terms
- Bullet lists for 3+ related items
- Numbered lists for sequential steps only
- Tables for comparisons or structured data
- No em dashes (use "..." or rewrite)

### Word Count
- Target: 1,500-2,000 words per lesson
- Write 1,800-2,200 to hit target after formatting overhead

### Example Prompts
- Minimum 3 per lesson
- Format as code blocks
- Include expected behavior or what to observe
- Mix of simple and slightly complex
- Test in actual AI tools before publishing

---

## Quality Checklist

Before marking a lesson complete, verify:

- [ ] All 6 required sections present in order
- [ ] 3-5 learning objectives with action verbs
- [ ] 3-5 content sections with H2 headings
- [ ] 3+ example prompts as code blocks
- [ ] 1 hands-on exercise with clear instructions
- [ ] 3+ source URLs (verifiable)
- [ ] Word count 1,500-2,000
- [ ] No em dashes
- [ ] No unexplained jargon
- [ ] Reading level grade 8 or below
- [ ] All factual claims traceable to sources
- [ ] Exercise works with free-tier tools
- [ ] Flows logically from previous lesson (if applicable)
- [ ] Leads naturally into next lesson (if applicable)

---

## Lesson Metadata

For Sanity CMS:

| Field | Requirement |
|-------|-------------|
| `title` | Short, plain-English (max 80 chars) |
| `slug` | URL-friendly, lowercase, hyphens |
| `order` | Integer for sequencing within module |
| `bodyAi` | AI-generated portable text content |
| `parent` | Reference to parent module |
| `seo.title` | Max 60 characters |
| `seo.description` | Max 160 characters |

---

## Portable Text Conversion

When writing lesson content that will become Portable Text:

1. **H2s become Card titles** - Each `## Section Name` renders as a distinct Card
2. **Supported markdown:**
   - `**bold**` and `*italic*`
   - `` `inline code` ``
   - `- bullet` and `1. numbered` lists
   - `| col1 | col2 |` tables (first row = header)
   - Triple backticks for code blocks
   - URLs auto-link

---

## Example Lesson Flow

```
## Learning Objectives
- [3-5 bulleted objectives]

## Introduction
[2-3 paragraphs: hook, context, preview]

## [Content Section 1: Simple concept]
[300-400 words, concrete examples]

## [Content Section 2: Build on previous]
[300-400 words, more depth]

## [Content Section 3: Practical application]
[300-400 words, real-world usage]

## [Content Section 4: Edge cases / nuance]
[300-400 words, when things get tricky]

## Key Takeaways
- [3-5 bulleted conclusions]

## Try It Yourself
[Step-by-step exercise, 5-10 minutes]

## Sources
[3+ bare URLs with brief descriptions]
```

---

## Review Criteria for Sentinel

When reviewing a lesson, flag as blockers:

1. Missing required sections
2. Fewer than 3 example prompts
3. No verifiable sources
4. Em dashes present
5. Unexplained technical jargon
6. Exercise requires paid tools only
7. Word count under 1,200 or over 2,500
8. Factual claims without source support
9. Lesson does not connect to adjacent lessons (if part of a sequence)
