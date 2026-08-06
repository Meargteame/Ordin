import React from 'react';
import { Target, Plus, CheckCircle2, Circle, TrendingUp } from 'lucide-react';
import { useApp } from '../context/AppContext';

export default function GoalsView() {
  const { goals, updateGoalProgress, setCreateModalType, lifeAreas } = useApp();

  const getLifeAreaColor = (catId) => {
    const area = lifeAreas.find(a => a.id === catId);
    return area ? area.color : 'purple';
  };

  return (
    <div className="page-view">
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '1.75rem', flexWrap: 'wrap', gap: '1rem' }}>
        <div>
          <h1 style={{ fontSize: '1.8rem', fontWeight: '800', display: 'flex', alignItems: 'center', gap: '0.6rem' }}>
            <Target size={26} style={{ color: 'var(--purple)' }} />
            <span>Strategic Goals & OKRs</span>
          </h1>
          <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem' }}>
            High-level objectives aligned across all core life areas
          </p>
        </div>

        <button className="btn btn-primary" onClick={() => setCreateModalType('goal')}>
          <Plus size={18} />
          <span>New Goal</span>
        </button>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(360px, 1fr))', gap: '1.5rem' }}>
        {goals.map(goal => {
          const colorBadge = getLifeAreaColor(goal.lifeArea);

          return (
            <div key={goal.id} className="ordin-card interactive" style={{ display: 'flex', flexDirection: 'column', gap: '1.25rem' }}>
              <div>
                <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '0.5rem' }}>
                  <span className={`badge badge-${colorBadge}`}>{goal.lifeArea}</span>
                  <span style={{ fontSize: '0.8rem', color: 'var(--text-tertiary)' }}>
                    Target: {goal.targetDate}
                  </span>
                </div>
                <h3 style={{ fontSize: '1.2rem', fontWeight: '700' }}>{goal.title}</h3>
              </div>

              {/* Progress Slider Bar */}
              <div>
                <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.85rem', marginBottom: '0.4rem', fontWeight: '600' }}>
                  <span>Progress</span>
                  <span style={{ color: 'var(--accent-lime)' }}>{goal.progress}%</span>
                </div>
                <input
                  type="range"
                  min="0"
                  max="100"
                  value={goal.progress}
                  onChange={(e) => updateGoalProgress(goal.id, Number(e.target.value))}
                  style={{ width: '100%', accentColor: 'var(--accent-lime)', cursor: 'pointer' }}
                />
              </div>

              {/* Key Results Checklist */}
              {goal.keyResults && goal.keyResults.length > 0 && (
                <div style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem', backgroundColor: 'rgba(255,255,255,0.03)', padding: '0.75rem', borderRadius: 'var(--radius-sm)' }}>
                  <span style={{ fontSize: '0.75rem', fontWeight: '700', color: 'var(--text-tertiary)', textTransform: 'uppercase' }}>
                    Key Results
                  </span>
                  {goal.keyResults.map(kr => (
                    <div key={kr.id} style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', fontSize: '0.85rem' }}>
                      {kr.completed ? (
                        <CheckCircle2 size={16} style={{ color: 'var(--accent-lime)' }} />
                      ) : (
                        <Circle size={16} style={{ color: 'var(--text-tertiary)' }} />
                      )}
                      <span style={{ textDecoration: kr.completed ? 'line-through' : 'none' }}>{kr.text}</span>
                    </div>
                  ))}
                </div>
              )}
            </div>
          );
        })}
      </div>
    </div>
  );
}
