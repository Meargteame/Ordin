# Ordin - Design Brief for UI/UX Designer

## Project Overview
**App Name:** Ordin  
**Platform:** Mobile (iOS & Android) - Flutter  
**Target Price:** $10-30/month subscription  
**Current Status:** Functional MVP with poor UI that needs complete redesign

## What is Ordin?
Ordin is a **personal life management super-app** - think of it as "16 mini-apps in one" for managing your entire life. It's for people who want ONE app to control everything instead of juggling 10+ different apps.

## The Problemf
The current UI looks generic, AI-generated, and cheap. It doesn't inspire confidence or justify a premium subscription price. Users need to feel like they're using a $30/month product, not a free app.

---

## App Structure

### Main Navigation (Bottom Tab Bar)
1. **Today** - Dashboard/home screen (most important)
2. **Tasks** - Task management
3. **Habits** - Daily habit tracking
4. **More** - Access to other 12 mini-apps  
4. **Goals** - Long-term goal setting and tracking
5. **Projects** - Multi-task project management
6. **Time Tracking** - Track time spent on activities
7. **Calendar** - Schedule and time blocking

#### Knowledge & Reflection
8. **Notes** - Quick note-taking
9. **Journal** - Daily journaling and gratitude

#### Life Areas
10. **Health** - Workouts, sleep, nutrition tracking
11. **Finance** - Expense tracking and budgets
12. **Relationships** - Important people, birthdays, interactions
13. **Learning** - Books, courses, skills tracking

#### Insights & Settings
14. **Analytics** - Productivity insights and trends
15. **Settings** - App preferences
16. **Export** - Data backup

---

## Design Requirements

### 1. TODAY SCREEN (Most Critical)
This is the main dashboard - the command center for your entire life.

**Must Include:**
- **Hero Header Section**
  - Greeting (Good Morning/Afternoon/Evening)
  - Current date
  - Overall completion percentage for the day
  - Visual progress indicator

- **Quick Stats Cards** (3 cards in a row)
  - Tasks completed (X/Y)
  - Habits completed (X/Y)
  - Current streak (fire emoji)

- **Life Areas Grid** (4x3 or 4x2 grid)
  - Quick access to all 12 mini-apps
  - Each with icon and label
  - Tappable cards

- **Today's Tasks Section**
  - List of tasks due today
  - Checkbox to complete
  - Priority indicators

- **Today's Habits Section**
  - List of habits scheduled for today
  - Checkbox to complete
  - Streak badges

**Design Goals:**
- Should feel like a premium dashboard
- Clear visual hierarchy
- Easy to scan in 3 seconds
- Motivating and energizing

### 2. TASKS SCREEN
**Features:**
- Task list with checkboxes
- Priority levels (High/Medium/Low)
- Due dates
- Tags
- Subtasks
- Filters (All, Today, Upcoming, Completed)
- Search
- Add task button (FAB)

### 3. HABITS SCREEN
**Features:**
- Habit list with checkboxes
- Streak counters (fire icon + number)
- Category badges
- Frequency (Daily, Weekdays, Custom)
- Success rate percentage
- Add habit button (FAB)

### 4. MORE SCREEN
**Features:**
- Categorized list of remaining 12 mini-apps
- Each item shows: Icon, Title, Description
- Grouped by category:
  - Life Management
  - Knowledge & Reflection
  - Life Areas
  - Insights

---

## Design Style Requirements

### What We DON'T Want
❌ Generic Material Design look  
❌ Boring monochrome colors  
❌ Flat, lifeless cards  
❌ Weak typography  
❌ Looks like every other AI-generated app  
❌ Feels cheap or amateur  

### What We DO Want
✅ **Premium & Sophisticated** - Looks worth $30/month  
✅ **Bold & Confident** - Strong visual presence  
✅ **Modern & Fresh** - 2025 design trends  
✅ **Unique Identity** - Doesn't look like everyone else  
✅ **Energizing** - Makes you want to be productive  
✅ **Professional** - Could win design awards  

### Visual Style Direction
Think of these apps as inspiration:
- **Notion** - Bold, clean, modern
- **Linear** - Sophisticated, fast, premium
- **Superhuman** - Dark, powerful, confident
- **Things 3** - Beautiful, thoughtful, polished
- **Stripe Dashboard** - Professional, trustworthy

### Key Design Elements

**Typography:**
- Strong hierarchy (large headings, clear body text)
- Bold weights for emphasis
- Tight letter-spacing for modern feel
- Mix of sizes for visual interest

**Colors:**
- Primary brand color (open to suggestions - currently sky blue but flexible)
- Rich, saturated colors (not washed out)
- Proper use of gradients (not overused)
- Semantic colors (green for success, red for errors)
- Dark mode support (optional but nice)

**Cards & Components:**
- Depth through shadows and elevation
- Rounded corners (modern feel)
- Clear borders or subtle shadows
- Hover/press states
- Smooth animations

**Spacing:**
- Generous padding (not cramped)
- Clear sections
- Breathing room
- Consistent spacing system

**Icons:**
- Consistent style throughout
- Clear and recognizable
- Proper sizing
- Colored or outlined based on context

---

## Technical Constraints

### Platform
- **Flutter** (cross-platform mobile framework)
- Designs will be implemented in code, not native
- All standard Flutter widgets available
- Custom animations possible

### Screen Sizes
- Design for mobile only (no tablet/desktop yet)
- Support both iOS and Android
- Common sizes: iPhone 14 Pro, Samsung Galaxy S23

### Assets Needed
- No custom illustrations needed
- Use system icons or icon packs (Material Icons, Lucide, etc.)
- Colors defined in hex codes
- Typography using system fonts or Google Fonts

---

## Deliverables Needed

### 1. Design System
- Color palette (primary, secondary, semantic colors)
- Typography scale (font sizes, weights, line heights)
- Spacing system (4px, 8px, 12px, 16px, 24px, etc.)
- Border radius values
- Shadow/elevation styles
- Component library (buttons, cards, inputs, etc.)

### 2. Screen Designs (High Priority)
**Must Have:**
1. Today Screen (most important)
2. Tasks Screen
3. Habits Screen
4. More Screen

**Nice to Have:**
5. Task Detail Screen
6. Habit Detail Screen
7. One of the mini-app screens (Goals, Projects, etc.)

### 3. Component Specifications
- Button styles (primary, secondary, text)
- Card styles
- Input fields
- Checkboxes
- Progress bars
- Badges/chips
- Navigation bar
- Headers

### 4. Interaction States
- Default state
- Hover/pressed state
- Disabled state
- Loading state
- Empty states
- Error states

---

## Design Format

### Preferred Tools
- **Figma** (preferred)
- Sketch
- Adobe XD
- Any tool that exports to PNG/PDF

### File Organization
- One file with all screens
- Organized by screen name
- Include design system/style guide page
- Annotate spacing and measurements
- Export at 2x or 3x resolution

### Annotations Needed
- Color hex codes
- Font names and sizes
- Spacing measurements (padding, margins)
- Border radius values
- Shadow specifications
- Any special interactions

---

## Success Criteria

A successful design will:
1. ✅ Make users say "Wow, this looks professional"
2. ✅ Justify a $10-30/month subscription price
3. ✅ Stand out from generic productivity apps
4. ✅ Be easy to implement in Flutter
5. ✅ Work well on both iOS and Android
6. ✅ Scale to 16 different mini-apps with consistent style
7. ✅ Be usable and accessible (not just pretty)

---

## Current State (For Reference)

### What's Working
- App is functional with all features built
- Data models are solid
- Navigation structure is good
- Bottom tab bar works well

### What's Broken
- UI looks generic and cheap
- Colors are inconsistent
- Typography is weak
- Cards look flat and boring
- No visual hierarchy
- Doesn't feel premium
- Looks like every other AI-generated app

---

## Questions for Designer

1. What's your recommended primary brand color?
2. Should we use gradients? If so, where?
3. Light mode, dark mode, or both?
4. Any custom illustrations needed?
5. What's your timeline and pricing?
6. Do you need access to the current app to see it?
7. How many revision rounds included?

---

## Contact & Next Steps

**What I'll Provide:**
- Screenshots of current app
- Access to live app (if needed)
- Quick feedback on drafts
- Clear direction on what works/doesn't work

**What I Need From You:**
- Initial concepts/mood boards (optional)
- First draft of Today screen
- Full design system
- All 4 main screens designed
- Component specifications
- Figma file (or equivalent)

**Timeline:**
- Ideally 1-2 weeks for initial designs
- Quick iteration based on feedback
- Final delivery with all assets and specs

---

## Budget
Open to discussion based on scope and your experience. This is a real product that will be launched, not a practice project.

---

## Additional Notes

- This app is for personal use initially, but may be released publicly
- Design should be scalable (we may add more features)
- Accessibility matters (readable text, good contrast)
- Performance matters (not too many heavy animations)
- The goal is to build something I'd actually want to use every day

---

**Ready to make Ordin look amazing? Let's talk!**
