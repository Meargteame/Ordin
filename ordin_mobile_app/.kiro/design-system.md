# Ordin Design System - Based on Reference

## Colors (Exact from Reference)
- Background Gradient: #B8B5E8 → #9D98D9 (top to bottom)
- Primary Blue: #5B7FFF
- Card White: #FFFFFF
- Text Dark: #1A1A1A
- Text Gray: #666666
- Text Light: #999999
- Success Green: #00C853
- Warning Orange: #FFB300
- Error Red: #FF5252

## Typography
- Heading 1: 20px, Bold (700)
- Heading 2: 18px, Bold (700)
- Heading 3: 16px, SemiBold (600)
- Body: 14px, Regular (400)
- Caption: 12px, Regular (400)
- Button: 15px, SemiBold (600)

## Spacing
- Screen Padding: 20px
- Card Padding: 24px
- Element Spacing: 12px, 16px, 20px, 24px
- Border Radius: 24px (cards), 12px (buttons), 16px (small cards)

## Shadows
- Card Shadow: rgba(0,0,0,0.08), blur 20px, offset (0,8)
- Small Card: rgba(0,0,0,0.06), blur 12px, offset (0,4)

## Components

### Main Card
- White background
- 24px border radius
- Soft shadow
- 24px padding
- Full width minus 40px (20px each side)

### Stat Card (2x2 Grid)
- Colored background (8% opacity)
- 16px border radius
- 16px padding
- Icon in colored container (15% opacity, 8px radius)
- Label (caption style)
- Value (18px, bold)

### Bar Chart
- 6 bars
- Rounded tops (8px radius)
- Primary blue color
- Month labels below
- Height: 120px

### List Item
- Icon container (40px, 10px radius, colored background 10% opacity)
- Title (body, semibold)
- Subtitle (caption)
- Chevron right (light gray)
- 12px spacing between items

### Bottom Navigation
- White background
- 4 icons
- No labels
- Blue when active
- Light gray when inactive
- No elevation

### Buttons
- Primary: Blue background, white text, 12px radius
- Secondary: Black background, white text, 12px radius
- Height: 48px
- Padding: 16px horizontal

## Screen Layouts

### Home Screen (Today)
1. Header (profile + name + actions)
2. Main white card containing:
   - "Today's Summary" title
   - 2x2 stat grid
   - "Weekly Progress" title
   - Bar chart
   - "Recent Activity" title with "View all"
   - Activity list (3 items)

### Tasks Screen
1. Header (title + count)
2. List of task cards
3. FAB (bottom right, white, "+ New Task")

### Habits Screen  
1. Header (title + count)
2. Badge ("Track streak" yellow)
3. List of habit cards
4. FAB (bottom right, white, "+ New Habit")

### More Screen
1. Header (title + actions)
2. List of feature cards with icons
