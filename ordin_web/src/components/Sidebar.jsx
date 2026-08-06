import React from 'react';
import {
  CheckSquare,
  Flame,
  Target,
  FolderKanban,
  Calendar,
  BookOpen,
  BarChart3,
  Settings,
  LayoutDashboard,
  Timer,
  Plus,
  Command,
  Zap
} from 'lucide-react';
import { useApp } from '../context/AppContext';

export default function Sidebar() {
  const {
    activeView,
    setActiveView,
    tasks,
    habits,
    openTimerWithTask,
    setIsCommandPaletteOpen,
    setCreateModalType
  } = useApp();

  const todayStr = new Date().toISOString().split('T')[0];
  const pendingTodayTasks = tasks.filter(t => !t.completed && t.dueDate === todayStr).length;
  const pendingHabitsToday = habits.filter(h => !h.completedDates.includes(todayStr)).length;

  const navItems = [
    { id: 'today', label: 'Today View', icon: LayoutDashboard, badge: pendingTodayTasks > 0 ? pendingTodayTasks : null, badgeColor: 'lime' },
    { id: 'tasks', label: 'Tasks', icon: CheckSquare },
    { id: 'habits', label: 'Habits', icon: Flame, badge: pendingHabitsToday > 0 ? pendingHabitsToday : null, badgeColor: 'orange' },
    { id: 'goals', label: 'Goals (OKRs)', icon: Target },
    { id: 'projects', label: 'Projects', icon: FolderKanban },
    { id: 'calendar', label: 'Time Blocks', icon: Calendar },
    { id: 'journal', label: 'Journal & Notes', icon: BookOpen },
    { id: 'analytics', label: 'Analytics', icon: BarChart3 },
    { id: 'settings', label: 'Settings', icon: Settings }
  ];

  return (
    <aside style={{
      width: '260px',
      height: '100vh',
      backgroundColor: 'var(--bg-sidebar)',
      borderRight: '1px solid var(--border-color)',
      display: 'flex',
      flexDirection: 'column',
      padding: '1.25rem 1rem',
      flexShrink: 0,
      userSelect: 'none'
    }}>
      {/* Brand Header */}
      <div style={{
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
        marginBottom: '1.75rem',
        padding: '0 0.5rem'
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '0.65rem' }}>
          <div style={{
            width: '34px',
            height: '34px',
            borderRadius: '10px',
            backgroundColor: 'var(--accent-lime)',
            color: 'var(--text-on-lime)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            fontWeight: '800',
            fontSize: '1.1rem',
            boxShadow: '0 0 15px rgba(212, 255, 0, 0.3)'
          }}>
            O
          </div>
          <div>
            <span style={{
              fontFamily: 'var(--font-heading)',
              fontWeight: '800',
              fontSize: '1.25rem',
              letterSpacing: '-0.03em'
            }}>
              ORDIN
            </span>
            <span style={{
              display: 'block',
              fontSize: '0.68rem',
              color: 'var(--accent-lime)',
              fontWeight: '600',
              letterSpacing: '0.08em',
              textTransform: 'uppercase'
            }}>
              Execution OS
            </span>
          </div>
        </div>
      </div>

      {/* Quick Action Buttons */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem', marginBottom: '1.5rem' }}>
        <button
          className="btn btn-primary"
          onClick={() => setCreateModalType('task')}
          style={{ width: '100%', justifyContent: 'flex-start', padding: '0.65rem 0.9rem' }}
        >
          <Plus size={18} />
          <span>New Task</span>
        </button>

        <button
          className="btn btn-secondary"
          onClick={() => openTimerWithTask(null)}
          style={{ width: '100%', justifyContent: 'flex-start', padding: '0.65rem 0.9rem' }}
        >
          <Timer size={18} style={{ color: 'var(--accent-lime)' }} />
          <span>Focus Mode</span>
        </button>
      </div>

      {/* Navigation List */}
      <nav style={{ display: 'flex', flexDirection: 'column', gap: '0.25rem', flex: 1, overflowY: 'auto' }}>
        <div style={{
          fontSize: '0.7rem',
          fontWeight: '700',
          color: 'var(--text-tertiary)',
          padding: '0.5rem 0.6rem 0.25rem',
          letterSpacing: '0.08em',
          textTransform: 'uppercase'
        }}>
          Navigation
        </div>

        {navItems.map(item => {
          const Icon = item.icon;
          const isActive = activeView === item.id;
          return (
            <button
              key={item.id}
              onClick={() => setActiveView(item.id)}
              style={{
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
                padding: '0.65rem 0.8rem',
                borderRadius: 'var(--radius-sm)',
                color: isActive ? 'var(--text-primary)' : 'var(--text-secondary)',
                backgroundColor: isActive ? 'rgba(255, 255, 255, 0.08)' : 'transparent',
                borderLeft: isActive ? '3px solid var(--accent-lime)' : '3px solid transparent',
                fontWeight: isActive ? '600' : '400',
                transition: 'all var(--transition-fast)',
                fontSize: '0.9rem'
              }}
            >
              <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
                <Icon size={18} style={{ color: isActive ? 'var(--accent-lime)' : 'inherit' }} />
                <span>{item.label}</span>
              </div>
              {item.badge && (
                <span className={`badge badge-${item.badgeColor}`}>
                  {item.badge}
                </span>
              )}
            </button>
          );
        })}
      </nav>

      {/* Shortcut Command Indicator */}
      <div
        onClick={() => setIsCommandPaletteOpen(true)}
        style={{
          marginTop: 'auto',
          padding: '0.75rem',
          borderRadius: 'var(--radius-sm)',
          backgroundColor: 'rgba(255, 255, 255, 0.03)',
          border: '1px solid var(--border-color)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          cursor: 'pointer',
          fontSize: '0.8rem',
          color: 'var(--text-secondary)'
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
          <Zap size={15} style={{ color: 'var(--accent-lime)' }} />
          <span>Quick Jump</span>
        </div>
        <kbd style={{
          backgroundColor: 'var(--card-elevated)',
          border: '1px solid var(--border-color)',
          borderRadius: '4px',
          padding: '0.1rem 0.4rem',
          fontSize: '0.75rem',
          fontFamily: 'var(--font-mono)'
        }}>
          Ctrl + K
        </kbd>
      </div>
    </aside>
  );
}
