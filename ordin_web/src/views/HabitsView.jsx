import React from 'react';
import { Flame, Plus, CheckCircle2, Trophy, Zap, Trash2 } from 'lucide-react';
import { useApp } from '../context/AppContext';

export default function HabitsView() {
  const { habits, toggleHabitToday, deleteHabit, setCreateModalType, lifeAreas } = useApp();

  const todayStr = new Date().toISOString().split('T')[0];

  // Generate last 7 days for weekly habit matrix
  const last7Days = Array.from({ length: 7 }, (_, i) => {
    const d = new Date();
    d.setDate(d.getDate() - (6 - i));
    return d.toISOString().split('T')[0];
  });

  const getDayName = (dateStr) => {
    const d = new Date(dateStr);
    return d.toLocaleDateString('en-US', { weekday: 'narrow' });
  };

  const getLifeAreaColor = (catId) => {
    const area = lifeAreas.find(a => a.id === catId);
    return area ? area.color : 'orange';
  };

  return (
    <div className="page-view">
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '1.75rem', flexWrap: 'wrap', gap: '1rem' }}>
        <div>
          <h1 style={{ fontSize: '1.8rem', fontWeight: '800', display: 'flex', alignItems: 'center', gap: '0.6rem' }}>
            <Flame size={26} style={{ color: 'var(--orange)' }} />
            <span>Habit Tracking System</span>
          </h1>
          <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem' }}>
            Build momentum with daily consistency and uninterrupted streaks
          </p>
        </div>

        <button className="btn btn-primary" onClick={() => setCreateModalType('habit')}>
          <Plus size={18} />
          <span>New Habit</span>
        </button>
      </div>

      {/* Habit Matrix Grid */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))', gap: '1.25rem' }}>
        {habits.map(habit => {
          const isDoneToday = habit.completedDates.includes(todayStr);
          const colorBadge = getLifeAreaColor(habit.category);

          return (
            <div key={habit.id} className="ordin-card interactive" style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                <div>
                  <span className={`badge badge-${colorBadge}`} style={{ marginBottom: '0.4rem' }}>
                    {habit.category}
                  </span>
                  <h3 style={{ fontSize: '1.1rem', fontWeight: '700' }}>{habit.title}</h3>
                </div>

                <button className="btn-icon" onClick={() => deleteHabit(habit.id)} title="Delete Habit">
                  <Trash2 size={16} />
                </button>
              </div>

              {/* Streak Stats */}
              <div style={{ display: 'flex', gap: '1rem', backgroundColor: 'rgba(255, 255, 255, 0.03)', padding: '0.75rem', borderRadius: 'var(--radius-sm)' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '0.4rem', color: 'var(--orange)', fontWeight: '700' }}>
                  <Flame size={18} />
                  <span>{habit.streak}d Current Streak</span>
                </div>
                <div style={{ display: 'flex', alignItems: 'center', gap: '0.4rem', color: 'var(--text-tertiary)', fontSize: '0.85rem' }}>
                  <Trophy size={16} />
                  <span>Max: {habit.maxStreak}d</span>
                </div>
              </div>

              {/* 7-Day Matrix Visual */}
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', paddingTop: '0.5rem', borderTop: '1px solid var(--border-color)' }}>
                {last7Days.map(dateStr => {
                  const isDone = habit.completedDates.includes(dateStr);
                  const isToday = dateStr === todayStr;

                  return (
                    <div 
                      key={dateStr}
                      onClick={() => isToday && toggleHabitToday(habit.id)}
                      style={{
                        display: 'flex',
                        flexDirection: 'column',
                        alignItems: 'center',
                        gap: '0.35rem',
                        cursor: isToday ? 'pointer' : 'default'
                      }}
                    >
                      <span style={{ fontSize: '0.7rem', color: isToday ? 'var(--accent-lime)' : 'var(--text-tertiary)', fontWeight: '700' }}>
                        {getDayName(dateStr)}
                      </span>
                      <div style={{
                        width: '28px',
                        height: '28px',
                        borderRadius: '8px',
                        backgroundColor: isDone ? 'var(--orange)' : 'rgba(255, 255, 255, 0.05)',
                        border: isToday ? '1px solid var(--orange)' : '1px solid transparent',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        color: '#000'
                      }}>
                        {isDone && <CheckCircle2 size={16} />}
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
