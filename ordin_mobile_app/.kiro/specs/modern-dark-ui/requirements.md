# Modern Dark UI Redesign - Requirements

## Overview
Complete UI redesign based on modern productivity app aesthetic with dark theme and lime accent color.

## Design Principles
1. **Dark-first design** - Black/dark gray backgrounds with high contrast
2. **Lime accent** - Distinctive yellow-lime (#D4FF00) for primary actions and highlights
3. **Card-based layout** - Rounded cards with subtle shadows
4. **Team collaboration focus** - Avatar groups, team tags, assignees
5. **Time-aware** - Calendar integration, time blocks, scheduling
6. **Minimal and clean** - Generous spacing, clear hierarchy

## Color System

### Primary Colors
- **Lime Accent**: #D4FF00 (primary CTA, highlights, selected states)
- **Dark Background**: #0F0F0F (main background)
- **Card Background**: #1A1A1A (elevated surfaces)
- **Card Elevated**: #2A2A2A (interactive cards)

### Text Colors
- **Primary Text**: #FFFFFF (headings, important text)
- **Secondary Text**: #A0A0A0 (descriptions, metadata)
- **Tertiary Text**: #666666 (timestamps, subtle info)

### Semantic Colors
- **Team Meeting**: #8B7FFF (purple)
- **Personal**: #FF6B9D (pink)
- **Work**: #4A9EFF (blue)
- **Success**: #00D9A0 (green)
- **Warning**: #FFB800 (orange)
- **Error**: #FF4757 (red)

## Typography

### Font Family
- Primary: SF Pro / Inter
- Monospace: SF Mono (for time, numbers)

### Scale
- **Display**: 32px, Bold, -0.5px letter-spacing
- **Heading Large**: 24px, Bold, -0.3px letter-spacing
- **Heading Medium**: 20px, Semibold, -0.2px letter-spacing
- **Body Large**: 17px, Regular
- **Body Medium**: 15px, Regular
- **Body Small**: 13px, Regular
- **Label**: 12px, Medium, 0.5px letter-spacing (uppercase)

## Spacing System
- **Base unit**: 4px
- **xs**: 4px
- **sm**: 8px
- **md**: 12px
- **lg**: 16px
- **xl**: 20px
- **2xl**: 24px
- **3xl**: 32px
- **4xl**: 40px

## Border Radius
- **Small**: 8px (tags, pills)
- **Medium**: 12px (buttons, inputs)
- **Large**: 16px (cards)
- **XLarge**: 20px (major cards)
- **2XLarge**: 24px (hero cards)
- **Round**: 999px (circular elements)

## Component Specifications

### Cards
- Background: #1A1A1A or #2A2A2A
- Border radius: 16-20px
- Padding: 16-20px
- Shadow: subtle, 0 4px 12px rgba(0,0,0,0.3)

### Buttons
- **Primary**: Lime background, black text, 12px radius
- **Secondary**: Dark gray background, white text, 12px radius
- **Icon**: Circular, 44px diameter
- Height: 44-48px
- Padding: 16px horizontal

### Tags/Pills
- Border radius: 8px
- Padding: 6px 12px
- Font size: 12px
- Background: Semi-transparent color

### Avatar Groups
- Size: 28-32px
- Overlap: -8px
- Border: 2px white
- Max visible: 4 (+N indicator)

### Bottom Action Bar
- Background: Dark with blur
- Border radius: 24px
- Padding: 12px
- Floating: 16px from bottom
- Shadow: 0 8px 24px rgba(0,0,0,0.4)

## Screen Requirements

### 1. Today Screen (Home)
**Header:**
- Greeting text: "Good Morning, [Name]"
- User avatar (top right)
- Date/time context

**Team Productivity Card:**
- Large lime card
- Team name
- Grid visualization (habit tracker style)
- Month/period selector

**Tasks Section:**
- "3 More Tasks to complete today"
- Task cards with:
  - Title
  - Time range
  - Team member avatars
  - Tag (Team meeting, Personal, etc.)
  - Background patterns for visual interest

**Bottom Action Bar:**
- 3 circular buttons: Menu, Add, Calendar
- Lime background
- Floating design

### 2. Calendar Screen
**Header:**
- Month/Year with dropdown
- Week view with date pills (current day highlighted in lime)
- Search icon

**Timeline:**
- Hourly slots (8 AM - 12 PM visible)
- Event cards with:
  - Title
  - Time range
  - Duration
  - Team avatars
  - Category tag
  - Background patterns (stripes, dots)
- Color-coded by type

**Events:**
- Morning Yoga (Personal, lime pattern)
- Daily sync (Team meeting, purple, avatars)
- Design review (Work, dark, avatars)
- Prepare presentation (Lime highlight)

**Bottom Action Bar:**
- Same as Today screen

### 3. Task Detail Screen
**Header:**
- Back button
- Task ID: #1283
- Edit icon

**Content Card:**
- Tag: "Team meeting" (purple pill)
- Priority: "Normal priority" (gray pill)
- Project: "#PrimaVita Project" (gray text)
- Title: Large, bold
- Time: "10 AM - 10:30 AM • 30 m • repeat weekly"
- Due: "due Today 10:30" (red text)

**Assignees:**
- "You" with avatar
- "Sara Perkinson" (Teamlead) with avatar

**Description:**
- Full text paragraph
- Clear, readable

**CTA Button:**
- "Join meeting • starts in 28 m"
- Full width
- Dark background
- White text

### 4. More/Menu Screen
(To be designed based on same principles)

## User Stories

### US-1: Dark Theme Experience
**As a** user  
**I want** a dark-themed interface  
**So that** I can use the app comfortably in low-light conditions

**Acceptance Criteria:**
- All screens use dark backgrounds (#0F0F0F, #1A1A1A)
- Text has sufficient contrast (WCAG AA)
- Lime accent is used sparingly for emphasis
- No pure white backgrounds

### US-2: Visual Hierarchy
**As a** user  
**I want** clear visual hierarchy  
**So that** I can quickly scan and understand information

**Acceptance Criteria:**
- Card-based layout with clear separation
- Consistent spacing system
- Typography scale creates clear hierarchy
- Important actions use lime accent

### US-3: Team Collaboration
**As a** user  
**I want** to see team member involvement  
**So that** I know who's working on what

**Acceptance Criteria:**
- Avatar groups show team members
- Tags indicate meeting types
- Assignees clearly displayed
- Team context visible on cards

### US-4: Time Awareness
**As a** user  
**I want** time-based organization  
**So that** I can manage my schedule effectively

**Acceptance Criteria:**
- Calendar view with week navigation
- Time slots for events
- Duration indicators
- Due dates and countdowns

## Correctness Properties

### CP-1: Color Contrast
**Property**: All text must meet WCAG AA contrast ratio (4.5:1 for normal text, 3:1 for large text)
**Test**: Automated contrast checker on all text/background combinations

### CP-2: Touch Targets
**Property**: All interactive elements must be at least 44x44 points
**Test**: Measure all buttons, links, and interactive areas

### CP-3: Consistent Spacing
**Property**: All spacing must use the 4px base unit system
**Test**: Verify all margins and paddings are multiples of 4

### CP-4: Card Hierarchy
**Property**: Cards must have consistent elevation and shadow system
**Test**: Verify all cards use defined shadow levels

## Technical Requirements

### Dependencies
- No new dependencies required
- Use existing Flutter Material 3
- Custom theme implementation

### Performance
- Smooth 60fps animations
- Lazy loading for lists
- Efficient rendering

### Accessibility
- Screen reader support
- Sufficient color contrast
- Touch target sizes
- Semantic labels

## Out of Scope
- Light theme variant (dark only for now)
- Custom illustrations
- Advanced animations beyond basic transitions
- Tablet/desktop layouts
