import React, { createContext, useContext, useState, useEffect } from 'react';
import confetti from 'canvas-confetti';
import { 
  getInitialState, 
  saveToStorage, 
  loadFromStorage,
  exportAppData, 
  resetAllStorage 
} from '../utils/storage';

const AppContext = createContext();

const STORAGE_KEYS = {
  TASKS: 'ordin_tasks_v1',
  HABITS: 'ordin_habits_v1',
  GOALS: 'ordin_goals_v1',
  PROJECTS: 'ordin_projects_v1',
  TIME_BLOCKS: 'ordin_time_blocks_v1',
  JOURNAL: 'ordin_journal_v1',
  NOTES: 'ordin_notes_v1',
  FOCUS_TEXT: 'ordin_focus_text_v1',
  THEME: 'ordin_theme_v1'
};

export const AppProvider = ({ children }) => {
  const [initialData] = useState(getInitialState);

  // Default theme is Warm Wood & Tactile Gray Light Mode ('wood')
  const [theme, setTheme] = useState(() => loadFromStorage(STORAGE_KEYS.THEME, 'wood'));

  const [activeView, setActiveView] = useState('today');
  const [focusText, setFocusText] = useState(initialData.focusText);
  const [tasks, setTasks] = useState(initialData.tasks);
  const [habits, setHabits] = useState(initialData.habits);
  const [goals, setGoals] = useState(initialData.goals);
  const [projects, setProjects] = useState(initialData.projects);
  const [timeBlocks, setTimeBlocks] = useState(initialData.timeBlocks);
  const [journal, setJournal] = useState(initialData.journal);
  const [notes, setNotes] = useState(initialData.notes);
  const [lifeAreas] = useState(initialData.lifeAreas);

  // Focus Timer Modal State
  const [isTimerOpen, setIsTimerOpen] = useState(false);
  const [activeTimerTask, setActiveTimerTask] = useState(null);

  // Command Palette State (Cmd/Ctrl + K)
  const [isCommandPaletteOpen, setIsCommandPaletteOpen] = useState(false);

  // Quick Create Modal State
  const [createModalType, setCreateModalType] = useState(null);

  // Apply Theme Attribute to HTML root element
  useEffect(() => {
    document.documentElement.setAttribute('data-theme', theme);
    saveToStorage(STORAGE_KEYS.THEME, theme);
  }, [theme]);

  // Persist State Changes
  useEffect(() => { saveToStorage(STORAGE_KEYS.FOCUS_TEXT, focusText); }, [focusText]);
  useEffect(() => { saveToStorage(STORAGE_KEYS.TASKS, tasks); }, [tasks]);
  useEffect(() => { saveToStorage(STORAGE_KEYS.HABITS, habits); }, [habits]);
  useEffect(() => { saveToStorage(STORAGE_KEYS.GOALS, goals); }, [goals]);
  useEffect(() => { saveToStorage(STORAGE_KEYS.PROJECTS, projects); }, [projects]);
  useEffect(() => { saveToStorage(STORAGE_KEYS.TIME_BLOCKS, timeBlocks); }, [timeBlocks]);
  useEffect(() => { saveToStorage(STORAGE_KEYS.JOURNAL, journal); }, [journal]);
  useEffect(() => { saveToStorage(STORAGE_KEYS.NOTES, notes); }, [notes]);

  // Celebratory Confetti helper
  const triggerCelebration = () => {
    try {
      confetti({
        particleCount: 50,
        spread: 60,
        origin: { y: 0.8 },
        colors: theme === 'dark' ? ['#D4FF00', '#8B7FFF', '#00D9A0'] : ['#D97706', '#7C3AED', '#059669']
      });
    } catch (e) {}
  };

  // --- Task Actions ---
  const toggleTask = (taskId) => {
    setTasks(prev => prev.map(t => {
      if (t.id === taskId) {
        const nextCompleted = !t.completed;
        if (nextCompleted) triggerCelebration();
        return { ...t, completed: nextCompleted };
      }
      return t;
    }));
  };

  const addTask = (newTask) => {
    const taskObj = {
      id: `t-${Date.now()}`,
      completed: false,
      dueDate: new Date().toISOString().split('T')[0],
      subtasks: [],
      estimatedMinutes: 30,
      priority: 'medium',
      category: 'career',
      ...newTask
    };
    setTasks(prev => [taskObj, ...prev]);
  };

  const deleteTask = (taskId) => {
    setTasks(prev => prev.filter(t => t.id !== taskId));
  };

  const toggleSubtask = (taskId, subtaskId) => {
    setTasks(prev => prev.map(t => {
      if (t.id === taskId) {
        const updatedSubtasks = (t.subtasks || []).map(st => 
          st.id === subtaskId ? { ...st, completed: !st.completed } : st
        );
        return { ...t, subtasks: updatedSubtasks };
      }
      return t;
    }));
  };

  // --- Habit Actions ---
  const toggleHabitToday = (habitId) => {
    const todayStr = new Date().toISOString().split('T')[0];
    setHabits(prev => prev.map(h => {
      if (h.id === habitId) {
        const isDoneToday = h.completedDates.includes(todayStr);
        let updatedDates;
        let newStreak = h.streak;

        if (isDoneToday) {
          updatedDates = h.completedDates.filter(d => d !== todayStr);
          newStreak = Math.max(0, newStreak - 1);
        } else {
          updatedDates = [...h.completedDates, todayStr];
          newStreak = newStreak + 1;
          triggerCelebration();
        }

        return {
          ...h,
          completedDates: updatedDates,
          streak: newStreak,
          maxStreak: Math.max(h.maxStreak, newStreak)
        };
      }
      return h;
    }));
  };

  const addHabit = (newHabit) => {
    const habitObj = {
      id: `h-${Date.now()}`,
      streak: 0,
      maxStreak: 0,
      completedDates: [],
      frequency: 'daily',
      category: 'health',
      ...newHabit
    };
    setHabits(prev => [habitObj, ...prev]);
  };

  const deleteHabit = (habitId) => {
    setHabits(prev => prev.filter(h => h.id !== habitId));
  };

  // --- Goal Actions ---
  const addGoal = (newGoal) => {
    const goalObj = {
      id: `g-${Date.now()}`,
      progress: 0,
      status: 'in_progress',
      keyResults: [],
      lifeArea: 'career',
      targetDate: new Date(Date.now() + 90 * 86400000).toISOString().split('T')[0],
      ...newGoal
    };
    setGoals(prev => [goalObj, ...prev]);
  };

  const updateGoalProgress = (goalId, newProgress) => {
    setGoals(prev => prev.map(g => g.id === goalId ? { ...g, progress: newProgress } : g));
  };

  // --- Project Actions ---
  const addProject = (newProj) => {
    const projObj = {
      id: `p-${Date.now()}`,
      progress: 0,
      status: 'active',
      category: 'career',
      ...newProj
    };
    setProjects(prev => [projObj, ...prev]);
  };

  // --- Time Block Actions ---
  const addTimeBlock = (newBlock) => {
    const blockObj = {
      id: `tb-${Date.now()}`,
      completed: false,
      category: 'career',
      ...newBlock
    };
    setTimeBlocks(prev => [...prev, blockObj]);
  };

  const toggleTimeBlock = (blockId) => {
    setTimeBlocks(prev => prev.map(tb => tb.id === blockId ? { ...tb, completed: !tb.completed } : tb));
  };

  // --- Journal Actions ---
  const saveJournalEntry = (entry) => {
    const todayStr = new Date().toISOString().split('T')[0];
    setJournal(prev => {
      const existingIdx = prev.findIndex(j => j.date === todayStr);
      if (existingIdx >= 0) {
        const updated = [...prev];
        updated[existingIdx] = { ...updated[existingIdx], ...entry };
        return updated;
      }
      return [{ id: `j-${Date.now()}`, date: todayStr, ...entry }, ...prev];
    });
  };

  // --- Note Actions ---
  const addNote = (newNote) => {
    const noteObj = {
      id: `n-${Date.now()}`,
      tags: [],
      updatedAt: new Date().toISOString(),
      ...newNote
    };
    setNotes(prev => [noteObj, ...prev]);
  };

  const deleteNote = (noteId) => {
    setNotes(prev => prev.filter(n => n.id !== noteId));
  };

  const openTimerWithTask = (task = null) => {
    setActiveTimerTask(task);
    setIsTimerOpen(true);
  };

  return (
    <AppContext.Provider
      value={{
        theme,
        setTheme,
        activeView,
        setActiveView,
        focusText,
        setFocusText,
        tasks,
        habits,
        goals,
        projects,
        timeBlocks,
        journal,
        notes,
        lifeAreas,
        toggleTask,
        addTask,
        deleteTask,
        toggleSubtask,
        toggleHabitToday,
        addHabit,
        deleteHabit,
        addGoal,
        updateGoalProgress,
        addProject,
        addTimeBlock,
        toggleTimeBlock,
        saveJournalEntry,
        addNote,
        deleteNote,
        isTimerOpen,
        setIsTimerOpen,
        activeTimerTask,
        openTimerWithTask,
        isCommandPaletteOpen,
        setIsCommandPaletteOpen,
        createModalType,
        setCreateModalType,
        exportAppData,
        resetAllStorage
      }}
    >
      {children}
    </AppContext.Provider>
  );
};

export const useApp = () => useContext(AppContext);
