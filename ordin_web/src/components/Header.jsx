import React, { useState } from 'react';
import { Sparkles, Timer, CheckCircle2, Search, Sun, Moon, Palette } from 'lucide-react';
import { useApp } from '../context/AppContext';

export default function Header() {
  const {
    theme,
    setTheme,
    focusText,
    setFocusText,
    tasks,
    openTimerWithTask,
    setIsCommandPaletteOpen
  } = useApp();

  const [isEditingFocus, setIsEditingFocus] = useState(false);
  const [tempFocus, setTempFocus] = useState(focusText);

  const todayDateStr = new Date().toLocaleDateString('en-US', {
    weekday: 'short',
    month: 'short',
    day: 'numeric'
  });

  const todayStr = new Date().toISOString().split('T')[0];
  const todayTasks = tasks.filter(t => t.dueDate === todayStr);
  const completedTodayTasks = todayTasks.filter(t => t.completed).length;
  const taskProgressPct = todayTasks.length > 0
    ? Math.round((completedTodayTasks / todayTasks.length) * 100)
    : 0;

  const handleFocusSubmit = (e) => {
    if (e.key === 'Enter' || e.type === 'blur') {
      setFocusText(tempFocus);
      setIsEditingFocus(false);
    }
  };

  const cycleTheme = () => {
    if (theme === 'wood') setTheme('dark');
    else if (theme === 'dark') setTheme('slate');
    else setTheme('wood');
  };

  const getThemeLabel = () => {
    if (theme === 'wood') return 'Warm Wood (Light)';
    if (theme === 'dark') return 'Dark Obsidian';
    return 'Nordic Slate';
  };

  return (
    <header style={{
      height: '70px',
      backgroundColor: 'var(--card-dark)',
      borderBottom: '1px solid var(--border-color)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      padding: '0 2rem',
      sticky: 'top',
      top: 0,
      zIndex: 10,
      transition: 'background-color 0.3s ease, border-color 0.3s ease'
    }}>
      {/* Left Section: Focus Intention */}
      <div style={{ display: 'flex', alignItems: 'center', gap: '1rem', flex: 1, maxWidth: '580px' }}>
        <div style={{
          display: 'flex',
          alignItems: 'center',
          gap: '0.4rem',
          color: 'var(--accent-lime)',
          fontSize: '0.85rem',
          fontWeight: '700',
          textTransform: 'uppercase',
          letterSpacing: '0.05em',
          whiteSpace: 'nowrap'
        }}>
          <Sparkles size={16} />
          <span>Focus Intention:</span>
        </div>

        {isEditingFocus ? (
          <input
            type="text"
            className="ordin-input"
            value={tempFocus}
            onChange={(e) => setTempFocus(e.target.value)}
            onKeyDown={handleFocusSubmit}
            onBlur={handleFocusSubmit}
            autoFocus
            style={{ padding: '0.4rem 0.75rem', fontSize: '0.9rem' }}
          />
        ) : (
          <div
            onClick={() => { setTempFocus(focusText); setIsEditingFocus(true); }}
            title="Click to edit daily focus text"
            style={{
              color: 'var(--text-primary)',
              fontSize: '0.9rem',
              fontWeight: '500',
              cursor: 'pointer',
              whiteSpace: 'nowrap',
              overflow: 'hidden',
              textOverflow: 'ellipsis',
              padding: '0.3rem 0.6rem',
              borderRadius: 'var(--radius-sm)',
              border: '1px solid transparent',
              transition: 'all var(--transition-fast)'
            }}
            onMouseEnter={(e) => e.currentTarget.style.backgroundColor = 'rgba(0, 0, 0, 0.05)'}
            onMouseLeave={(e) => e.currentTarget.style.backgroundColor = 'transparent'}
          >
            "{focusText}"
          </div>
        )}
      </div>

      {/* Right Section: Progress Pill, Theme Switcher, Timer Button, Date */}
      <div style={{ display: 'flex', alignItems: 'center', gap: '0.85rem' }}>
        {/* Task Completion Progress Pill */}
        <div style={{
          display: 'flex',
          alignItems: 'center',
          gap: '0.65rem',
          backgroundColor: 'var(--bg-dark)',
          border: '1px solid var(--border-color)',
          borderRadius: 'var(--radius-full)',
          padding: '0.35rem 0.85rem',
          fontSize: '0.8rem'
        }}>
          <CheckCircle2 size={16} style={{ color: 'var(--accent-lime)' }} />
          <span style={{ color: 'var(--text-secondary)' }}>
            <strong style={{ color: 'var(--text-primary)' }}>{completedTodayTasks}/{todayTasks.length}</strong> Tasks ({taskProgressPct}%)
          </span>
          <div style={{
            width: '40px',
            height: '6px',
            backgroundColor: 'rgba(100, 100, 100, 0.2)',
            borderRadius: '10px',
            overflow: 'hidden'
          }}>
            <div style={{
              width: `${taskProgressPct}%`,
              height: '100%',
              backgroundColor: 'var(--accent-lime)',
              transition: 'width 0.3s ease'
            }} />
          </div>
        </div>

        {/* Theme Switcher Toggle */}
        <button
          className="btn btn-secondary"
          onClick={cycleTheme}
          title={`Current Theme: ${getThemeLabel()}. Click to switch theme.`}
          style={{ padding: '0.4rem 0.75rem', fontSize: '0.8rem', gap: '0.4rem' }}
        >
          {theme === 'wood' && <Sun size={15} style={{ color: 'var(--accent-lime)' }} />}
          {theme === 'dark' && <Moon size={15} style={{ color: 'var(--accent-lime)' }} />}
          {theme === 'slate' && <Palette size={15} style={{ color: 'var(--accent-lime)' }} />}
          <span>{theme === 'wood' ? 'Warm Wood' : theme === 'dark' ? 'Dark Mode' : 'Slate Gray'}</span>
        </button>

        {/* Search / Cmd+K Trigger */}
        <button
          className="btn-icon"
          onClick={() => setIsCommandPaletteOpen(true)}
          title="Search & Commands (Ctrl+K)"
        >
          <Search size={18} />
        </button>

        {/* Quick Focus Timer */}
        <button
          className="btn btn-primary"
          onClick={() => openTimerWithTask(null)}
          style={{ padding: '0.45rem 0.9rem', fontSize: '0.85rem' }}
        >
          <Timer size={16} />
          <span>Timer</span>
        </button>

        {/* Date Display */}
        <div style={{
          fontSize: '0.85rem',
          fontWeight: '600',
          color: 'var(--text-secondary)',
          fontFamily: 'var(--font-mono)'
        }}>
          {todayDateStr}
        </div>
      </div>
    </header>
  );
}
