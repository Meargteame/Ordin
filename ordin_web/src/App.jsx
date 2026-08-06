import React from 'react';
import { AppProvider, useApp } from './context/AppContext';
import Sidebar from './components/Sidebar';
import Header from './components/Header';
import FocusTimerModal from './components/FocusTimerModal';
import CommandPalette from './components/CommandPalette';
import CreateModal from './components/CreateModal';

import TodayView from './views/TodayView';
import TasksView from './views/TasksView';
import HabitsView from './views/HabitsView';
import GoalsView from './views/GoalsView';
import ProjectsView from './views/ProjectsView';
import CalendarView from './views/CalendarView';
import JournalView from './views/JournalView';
import AnalyticsView from './views/AnalyticsView';
import SettingsView from './views/SettingsView';

function MainAppLayout() {
  const { activeView } = useApp();

  const renderView = () => {
    switch (activeView) {
      case 'today': return <TodayView />;
      case 'tasks': return <TasksView />;
      case 'habits': return <HabitsView />;
      case 'goals': return <GoalsView />;
      case 'projects': return <ProjectsView />;
      case 'calendar': return <CalendarView />;
      case 'journal': return <JournalView />;
      case 'analytics': return <AnalyticsView />;
      case 'settings': return <SettingsView />;
      default: return <TodayView />;
    }
  };

  return (
    <div className="app-container">
      <Sidebar />
      <div className="main-content">
        <Header />
        {renderView()}
      </div>
      <FocusTimerModal />
      <CommandPalette />
      <CreateModal />
    </div>
  );
}

export default function App() {
  return (
    <AppProvider>
      <MainAppLayout />
    </AppProvider>
  );
}
