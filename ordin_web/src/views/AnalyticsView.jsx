import React from 'react';
import { BarChart3, TrendingUp, Flame, CheckCircle2, Award, Zap } from 'lucide-react';
import { useApp } from '../context/AppContext';

export default function AnalyticsView() {
  const { tasks, habits, goals, lifeAreas } = useApp();

  const totalTasks = tasks.length;
  const completedTasks = tasks.filter(t => t.completed).length;
  const taskRate = totalTasks > 0 ? Math.round((completedTasks / totalTasks) * 100) : 0;

  const totalHabits = habits.length;
  const avgStreak = habits.length > 0 
    ? Math.round(habits.reduce((acc, h) => acc + h.streak, 0) / habits.length) 
    : 0;

  const maxStreakAllTime = habits.length > 0
    ? Math.max(...habits.map(h => h.maxStreak))
    : 0;

  return (
    <div className="page-view">
      <div style={{ marginBottom: '1.75rem' }}>
        <h1 style={{ fontSize: '1.8rem', fontWeight: '800', display: 'flex', alignItems: 'center', gap: '0.6rem' }}>
          <BarChart3 size={26} style={{ color: 'var(--accent-lime)' }} />
          <span>Execution Analytics & Insights</span>
        </h1>
        <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem' }}>
          Data-driven overview of your execution performance and habit metrics
        </p>
      </div>

      {/* Hero Stats */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', gap: '1.25rem', marginBottom: '2rem' }}>
        <div className="ordin-card" style={{ borderColor: 'rgba(212, 255, 0, 0.3)' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', color: 'var(--accent-lime)', fontSize: '0.8rem', fontWeight: '700', textTransform: 'uppercase' }}>
            <CheckCircle2 size={16} />
            <span>Task Completion</span>
          </div>
          <div style={{ fontSize: '2.2rem', fontWeight: '800', margin: '0.4rem 0' }}>{taskRate}%</div>
          <span style={{ fontSize: '0.8rem', color: 'var(--text-tertiary)' }}>{completedTasks} of {totalTasks} total tasks completed</span>
        </div>

        <div className="ordin-card" style={{ borderColor: 'rgba(255, 184, 0, 0.3)' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', color: 'var(--orange)', fontSize: '0.8rem', fontWeight: '700', textTransform: 'uppercase' }}>
            <Flame size={16} />
            <span>Average Streak</span>
          </div>
          <div style={{ fontSize: '2.2rem', fontWeight: '800', margin: '0.4rem 0' }}>{avgStreak} days</div>
          <span style={{ fontSize: '0.8rem', color: 'var(--text-tertiary)' }}>Across all active habits</span>
        </div>

        <div className="ordin-card" style={{ borderColor: 'rgba(139, 127, 255, 0.3)' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', color: 'var(--purple)', fontSize: '0.8rem', fontWeight: '700', textTransform: 'uppercase' }}>
            <Award size={16} />
            <span>Best Streak</span>
          </div>
          <div style={{ fontSize: '2.2rem', fontWeight: '800', margin: '0.4rem 0' }}>{maxStreakAllTime} days</div>
          <span style={{ fontSize: '0.8rem', color: 'var(--text-tertiary)' }}>Personal record habit milestone</span>
        </div>
      </div>

      {/* Distribution by Life Area */}
      <div className="ordin-card" style={{ padding: '1.5rem' }}>
        <h2 style={{ fontSize: '1.2rem', fontWeight: '700', marginBottom: '1rem' }}>Life Area Balance</h2>
        <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
          {lifeAreas.map(la => {
            const count = tasks.filter(t => t.category === la.id).length;
            const pct = totalTasks > 0 ? Math.round((count / totalTasks) * 100) : 0;
            return (
              <div key={la.id}>
                <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.85rem', marginBottom: '0.35rem', fontWeight: '600' }}>
                  <span>{la.name}</span>
                  <span style={{ color: 'var(--text-secondary)' }}>{count} tasks ({pct}%)</span>
                </div>
                <div style={{ width: '100%', height: '8px', backgroundColor: 'rgba(255,255,255,0.06)', borderRadius: '10px', overflow: 'hidden' }}>
                  <div style={{ width: `${pct}%`, height: '100%', backgroundColor: `var(--${la.color})` }} />
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}
