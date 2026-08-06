import React, { useState, useEffect } from 'react';
import { Search, LayoutDashboard, CheckSquare, Flame, Target, FolderKanban, Calendar, BookOpen, BarChart3, Settings, Timer, Plus, X } from 'lucide-react';
import { useApp } from '../context/AppContext';

export default function CommandPalette() {
  const { 
    isCommandPaletteOpen, 
    setIsCommandPaletteOpen, 
    setActiveView, 
    tasks, 
    openTimerWithTask,
    setCreateModalType,
    toggleTask
  } = useApp();

  const [searchQuery, setSearchQuery] = useState('');

  // Keyboard shortcut listener for Ctrl+K / Cmd+K
  useEffect(() => {
    const handleKeyDown = (e) => {
      if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 'k') {
        e.preventDefault();
        setIsCommandPaletteOpen(prev => !prev);
      }
      if (e.key === 'Escape' && isCommandPaletteOpen) {
        setIsCommandPaletteOpen(false);
      }
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [isCommandPaletteOpen]);

  if (!isCommandPaletteOpen) return null;

  const viewsList = [
    { id: 'today', label: 'Go to Today Dashboard', icon: LayoutDashboard },
    { id: 'tasks', label: 'Go to Tasks System', icon: CheckSquare },
    { id: 'habits', label: 'Go to Habit Tracker', icon: Flame },
    { id: 'goals', label: 'Go to Goals & OKRs', icon: Target },
    { id: 'projects', label: 'Go to Projects', icon: FolderKanban },
    { id: 'calendar', label: 'Go to Time Blocking', icon: Calendar },
    { id: 'journal', label: 'Go to Journal & Notes', icon: BookOpen },
    { id: 'analytics', label: 'Go to Analytics', icon: BarChart3 },
    { id: 'settings', label: 'Go to Settings', icon: Settings }
  ];

  const filteredViews = viewsList.filter(v => 
    v.label.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const filteredTasks = tasks.filter(t => 
    t.title.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <div className="modal-overlay" onClick={() => setIsCommandPaletteOpen(false)}>
      <div 
        className="modal-card" 
        onClick={(e) => e.stopPropagation()}
        style={{ maxWidth: '560px', padding: '0', overflow: 'hidden' }}
      >
        {/* Search Input Bar */}
        <div style={{
          display: 'flex',
          alignItems: 'center',
          gap: '0.75rem',
          padding: '1.25rem 1.25rem 0.75rem',
          borderBottom: '1px solid var(--border-color)'
        }}>
          <Search size={20} style={{ color: 'var(--accent-lime)' }} />
          <input
            type="text"
            placeholder="Type a command, task title, or view..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            autoFocus
            style={{
              width: '100%',
              background: 'transparent',
              border: 'none',
              color: 'var(--text-primary)',
              fontSize: '1rem'
            }}
          />
          <button className="btn-icon" onClick={() => setIsCommandPaletteOpen(false)}>
            <X size={18} />
          </button>
        </div>

        {/* Command Results */}
        <div style={{ maxHeight: '350px', overflowY: 'auto', padding: '0.75rem' }}>
          {/* Quick Actions Header */}
          <div style={{
            fontSize: '0.7rem',
            fontWeight: '700',
            color: 'var(--text-tertiary)',
            textTransform: 'uppercase',
            letterSpacing: '0.08em',
            padding: '0.4rem 0.6rem'
          }}>
            Quick Actions
          </div>

          <button
            className="btn btn-ghost"
            style={{ width: '100%', justifyContent: 'flex-start', padding: '0.65rem' }}
            onClick={() => {
              setCreateModalType('task');
              setIsCommandPaletteOpen(false);
            }}
          >
            <Plus size={18} style={{ color: 'var(--accent-lime)' }} />
            <span>Create New Task</span>
          </button>

          <button
            className="btn btn-ghost"
            style={{ width: '100%', justifyContent: 'flex-start', padding: '0.65rem' }}
            onClick={() => {
              openTimerWithTask(null);
              setIsCommandPaletteOpen(false);
            }}
          >
            <Timer size={18} style={{ color: 'var(--purple)' }} />
            <span>Start Focus Session</span>
          </button>

          {/* Navigation Options */}
          {filteredViews.length > 0 && (
            <>
              <div style={{
                fontSize: '0.7rem',
                fontWeight: '700',
                color: 'var(--text-tertiary)',
                textTransform: 'uppercase',
                letterSpacing: '0.08em',
                padding: '0.6rem 0.6rem 0.3rem'
              }}>
                Views
              </div>
              {filteredViews.map(view => {
                const Icon = view.icon;
                return (
                  <button
                    key={view.id}
                    className="btn btn-ghost"
                    style={{ width: '100%', justifyContent: 'flex-start', padding: '0.6rem' }}
                    onClick={() => {
                      setActiveView(view.id);
                      setIsCommandPaletteOpen(false);
                    }}
                  >
                    <Icon size={18} style={{ color: 'var(--text-secondary)' }} />
                    <span>{view.label}</span>
                  </button>
                );
              })}
            </>
          )}

          {/* Tasks Results */}
          {searchQuery.trim() !== '' && filteredTasks.length > 0 && (
            <>
              <div style={{
                fontSize: '0.7rem',
                fontWeight: '700',
                color: 'var(--text-tertiary)',
                textTransform: 'uppercase',
                letterSpacing: '0.08em',
                padding: '0.6rem 0.6rem 0.3rem'
              }}>
                Matching Tasks
              </div>
              {filteredTasks.map(t => (
                <div
                  key={t.id}
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'space-between',
                    padding: '0.6rem',
                    borderRadius: 'var(--radius-sm)',
                    cursor: 'pointer'
                  }}
                  className="ordin-card"
                  onClick={() => {
                    toggleTask(t.id);
                    setIsCommandPaletteOpen(false);
                  }}
                >
                  <span style={{ fontSize: '0.9rem', textDecoration: t.completed ? 'line-through' : 'none' }}>
                    {t.title}
                  </span>
                  <span className={`badge badge-${t.completed ? 'green' : 'lime'}`}>
                    {t.completed ? 'Completed' : 'Toggle'}
                  </span>
                </div>
              ))}
            </>
          )}
        </div>
      </div>
    </div>
  );
}
