// Ordin Web Data Models & Local Storage Service

const STORAGE_KEYS = {
  TASKS: 'ordin_tasks_v1',
  HABITS: 'ordin_habits_v1',
  GOALS: 'ordin_goals_v1',
  PROJECTS: 'ordin_projects_v1',
  TIME_BLOCKS: 'ordin_time_blocks_v1',
  JOURNAL: 'ordin_journal_v1',
  NOTES: 'ordin_notes_v1',
  FOCUS_TEXT: 'ordin_focus_text_v1',
  SETTINGS: 'ordin_settings_v1',
};

// Initial Seed Data for immediate engagement
const DEFAULT_FOCUS_TEXT = "Build consistent execution habits & ship high-quality products today.";

const DEFAULT_LIFE_AREAS = [
  { id: 'health', name: 'Health & Fitness', color: 'green', icon: 'Heart' },
  { id: 'mind', name: 'Mind & Growth', color: 'purple', icon: 'Brain' },
  { id: 'career', name: 'Career & Work', color: 'blue', icon: 'Briefcase' },
  { id: 'finance', name: 'Finance & Wealth', color: 'orange', icon: 'DollarSign' },
  { id: 'relationships', name: 'Relationships', color: 'pink', icon: 'Users' }
];

const DEFAULT_TASKS = [
  {
    id: 't-1',
    title: 'Review today\'s priority execution plan',
    category: 'career',
    priority: 'high',
    completed: true,
    dueDate: new Date().toISOString().split('T')[0],
    estimatedMinutes: 20,
    subtasks: [
      { id: 'st-1', title: 'Check today dashboard', completed: true },
      { id: 'st-2', title: 'Align calendar time blocks', completed: true }
    ],
    goalId: 'g-1'
  },
  {
    id: 't-2',
    title: 'Ship Ordin Web App MVP',
    category: 'career',
    priority: 'high',
    completed: false,
    dueDate: new Date().toISOString().split('T')[0],
    estimatedMinutes: 60,
    subtasks: [
      { id: 'st-3', title: 'Setup React + Vite architecture', completed: true },
      { id: 'st-4', title: 'Implement dark mode UI components', completed: true },
      { id: 'st-5', title: 'Connect local storage state manager', completed: false }
    ],
    goalId: 'g-1'
  },
  {
    id: 't-3',
    title: '30-minute cardio focus session',
    category: 'health',
    priority: 'medium',
    completed: false,
    dueDate: new Date().toISOString().split('T')[0],
    estimatedMinutes: 30,
    subtasks: [],
    goalId: 'g-2'
  },
  {
    id: 't-4',
    title: 'Read 20 pages of Deep Work',
    category: 'mind',
    priority: 'medium',
    completed: false,
    dueDate: new Date().toISOString().split('T')[0],
    estimatedMinutes: 25,
    subtasks: [],
    goalId: 'g-3'
  }
];

const DEFAULT_HABITS = [
  {
    id: 'h-1',
    title: 'Morning Deep Focus Block (90m)',
    category: 'career',
    streak: 5,
    maxStreak: 12,
    completedDates: [
      new Date().toISOString().split('T')[0]
    ],
    frequency: 'daily'
  },
  {
    id: 'h-2',
    title: 'Hydration & Daily Movement',
    category: 'health',
    streak: 8,
    maxStreak: 14,
    completedDates: [
      new Date().toISOString().split('T')[0]
    ],
    frequency: 'daily'
  },
  {
    id: 'h-3',
    title: 'Evening Reflection & Journaling',
    category: 'mind',
    streak: 3,
    maxStreak: 7,
    completedDates: [],
    frequency: 'daily'
  }
];

const DEFAULT_GOALS = [
  {
    id: 'g-1',
    title: 'Master Ordin Execution OS',
    lifeArea: 'career',
    targetDate: '2026-12-31',
    progress: 75,
    status: 'in_progress',
    keyResults: [
      { id: 'kr-1', text: 'Build mobile and web clients', completed: true },
      { id: 'kr-2', text: 'Maintain 7-day execution streak', completed: false }
    ]
  },
  {
    id: 'g-2',
    title: 'Peak Physical Vitality',
    lifeArea: 'health',
    targetDate: '2026-09-30',
    progress: 60,
    status: 'in_progress',
    keyResults: [
      { id: 'kr-3', text: 'Exercise 5x weekly', completed: false }
    ]
  },
  {
    id: 'g-3',
    title: 'Continuous Mindful Learning',
    lifeArea: 'mind',
    targetDate: '2026-11-15',
    progress: 40,
    status: 'in_progress',
    keyResults: [
      { id: 'kr-4', text: 'Complete 10 strategic books', completed: false }
    ]
  }
];

const DEFAULT_PROJECTS = [
  {
    id: 'p-1',
    title: 'Ordin Web Platform',
    category: 'career',
    status: 'active',
    progress: 80,
    description: 'Web client for Ordin daily execution OS'
  },
  {
    id: 'p-2',
    title: 'Personal Health System',
    category: 'health',
    status: 'active',
    progress: 50,
    description: 'Diet, exercise, and recovery tracking framework'
  }
];

const DEFAULT_TIME_BLOCKS = [
  {
    id: 'tb-1',
    title: 'Deep Work: Ordin Web Development',
    startTime: '09:00',
    endTime: '11:30',
    category: 'career',
    completed: true
  },
  {
    id: 'tb-2',
    title: 'Lunch & Recharge',
    startTime: '12:00',
    endTime: '13:00',
    category: 'health',
    completed: true
  },
  {
    id: 'tb-3',
    title: 'Strategic Goals & System Planning',
    startTime: '14:00',
    endTime: '16:00',
    category: 'mind',
    completed: false
  }
];

const DEFAULT_JOURNAL = [
  {
    id: 'j-1',
    date: new Date().toISOString().split('T')[0],
    mood: 5, // 1 to 5
    focusRating: 4,
    gratitude: 'Grateful for fast progress and clear execution tools.',
    reflections: 'Substantial clarity achieved by organizing daily objectives.'
  }
];

const DEFAULT_NOTES = [
  {
    id: 'n-1',
    title: 'Ordin Core System Philosophy',
    content: '1. Clarity > Features\n2. Sub-300ms speed for all interactions\n3. Single-day focus first, long-term alignment second.',
    tags: ['philosophy', 'system'],
    updatedAt: new Date().toISOString()
  }
];

// Helper functions for LocalStorage
export function loadFromStorage(key, defaultValue) {
  try {
    const item = localStorage.getItem(key);
    return item ? JSON.parse(item) : defaultValue;
  } catch (error) {
    console.error(`Error loading ${key} from storage:`, error);
    return defaultValue;
  }
}

export function saveToStorage(key, value) {
  try {
    localStorage.setItem(key, JSON.stringify(value));
  } catch (error) {
    console.error(`Error saving ${key} to storage:`, error);
  }
}

export function getInitialState() {
  return {
    tasks: loadFromStorage(STORAGE_KEYS.TASKS, DEFAULT_TASKS),
    habits: loadFromStorage(STORAGE_KEYS.HABITS, DEFAULT_HABITS),
    goals: loadFromStorage(STORAGE_KEYS.GOALS, DEFAULT_GOALS),
    projects: loadFromStorage(STORAGE_KEYS.PROJECTS, DEFAULT_PROJECTS),
    timeBlocks: loadFromStorage(STORAGE_KEYS.TIME_BLOCKS, DEFAULT_TIME_BLOCKS),
    journal: loadFromStorage(STORAGE_KEYS.JOURNAL, DEFAULT_JOURNAL),
    notes: loadFromStorage(STORAGE_KEYS.NOTES, DEFAULT_NOTES),
    focusText: loadFromStorage(STORAGE_KEYS.FOCUS_TEXT, DEFAULT_FOCUS_TEXT),
    lifeAreas: DEFAULT_LIFE_AREAS
  };
}

export function exportAppData() {
  const data = {
    version: '1.0.0',
    exportedAt: new Date().toISOString(),
    focusText: loadFromStorage(STORAGE_KEYS.FOCUS_TEXT, DEFAULT_FOCUS_TEXT),
    tasks: loadFromStorage(STORAGE_KEYS.TASKS, DEFAULT_TASKS),
    habits: loadFromStorage(STORAGE_KEYS.HABITS, DEFAULT_HABITS),
    goals: loadFromStorage(STORAGE_KEYS.GOALS, DEFAULT_GOALS),
    projects: loadFromStorage(STORAGE_KEYS.PROJECTS, DEFAULT_PROJECTS),
    timeBlocks: loadFromStorage(STORAGE_KEYS.TIME_BLOCKS, DEFAULT_TIME_BLOCKS),
    journal: loadFromStorage(STORAGE_KEYS.JOURNAL, DEFAULT_JOURNAL),
    notes: loadFromStorage(STORAGE_KEYS.NOTES, DEFAULT_NOTES)
  };

  const jsonString = `data:text/json;charset=utf-8,${encodeURIComponent(JSON.stringify(data, null, 2))}`;
  const downloadAnchor = document.createElement('a');
  downloadAnchor.setAttribute('href', jsonString);
  downloadAnchor.setAttribute('download', `ordin_backup_${new Date().toISOString().split('T')[0]}.json`);
  document.body.appendChild(downloadAnchor);
  downloadAnchor.click();
  downloadAnchor.remove();
}

export function resetAllStorage() {
  Object.values(STORAGE_KEYS).forEach(key => localStorage.removeItem(key));
  window.location.reload();
}
