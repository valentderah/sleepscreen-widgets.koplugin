# Goal Widget Improvement Plan

## Current State
The goal widget on the sleep screen needs improvements for better usability and goal tracking.

## Proposed Improvements

### 1. Visual Enhancements
- [ ] Progress bar with gradient fill
- [ ] Color coding by goal type (reading, pages, time)
- [ ] Smooth animation on progress update
- [ ] Dark/light theme support

### 2. Goal Types
| Type | Metric | Unit | Display |
|------|--------|------|---------|
| Pages | Pages read | pages | Progress bar |
| Time | Reading time | minutes | Timer |
| Books | Books completed | books | Counter |
| Streak | Consecutive days | days | Flame icon |

### 3. Widget Layout
```
┌──────────────────────────┐
│  📖 Reading Goal          │
│  ████████░░░░ 67%         │
│  134/200 pages today      │
│  🔥 7 day streak          │
└──────────────────────────┘
```

### 4. Configuration
- Daily/weekly/monthly goal options
- Customizable widget position
- Font size adjustment
- Show/hide individual metrics

### 5. Data Storage
```lua
-- Goal state stored in settings
local goal_state = {
    daily_target = 200,        -- pages
    daily_progress = 134,      -- pages read today
    streak_days = 7,           -- consecutive days
    last_update = "2026-05-16",
    goal_type = "pages",       -- pages/time/books
}
```

### 6. Implementation Priority
1. Fix current rendering issues
2. Add progress bar
3. Add streak counter
4. Add configuration UI
5. Add multiple goal types
