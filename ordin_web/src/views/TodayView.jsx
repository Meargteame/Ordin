import React from 'react';
import {
  CheckCircle2,
  Flame,
  Timer,
  Plus,
  Clock,
  Trash2
} from 'lucide-react';
import { useApp } from '../context/AppContext';

export default function TodayView() {
  const {
    focusText,
    tasks,
    habits,
    toggleTask,
    toggleSubtask,
    deleteTask,
    toggleHabitToday,
    openTimerWithTask,
    setCreateModalType,
    lifeAreas
  } = useApp();

  const todayStr = new Date().toISOString().split('T')[0];
  const todayTasks = tasks.filter(t => t.dueDate === todayStr || !t.dueDate);
  const completedTasksCount = todayTasks.filter(t => t.completed).length;

  const totalEstMins = todayTasks.reduce((acc, t) => acc + (t.estimatedMinutes || 30), 0);
  const completedEstMins = todayTasks.filter(t => t.completed).reduce((acc, t) => acc + (t.estimatedMinutes || 30), 0);

  const executionScore = todayTasks.length > 0
    ? Math.round((completedTasksCount / todayTasks.length) * 100)
    : 100;

  const getLifeAreaColor = (catId) => {
    const area = lifeAreas.find(a => a.id === catId);
    return area ? area.color : 'lime';
  };

  return (
    <div className="page-view">
      {/* Today Header Hero */}
      <div className="ordin-card" style={{
        background: 'linear-gradient(135deg, var(--card-dark) 0%, var(--card-light) 100%)',
        borderColor: 'var(--border-color-hover)',
        padding: '1.75rem',
        marginBottom: '2rem',
        boxShadow: 'var(--shadow-sm)'
      }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', flexWrap: 'wrap', gap: '1.5rem' }}>
          <div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', marginBottom: '0.4rem' }}>
              <span className="badge badge-lime">Today's Operating View</span>
              <span style={{ fontSize: '0.8rem', color: 'var(--text-tertiary)' }}>• Local-first execution</span>
            </div>
            <h1 style={{ fontSize: '2rem', fontWeight: '800', marginBottom: '0.5rem' }}>
              Execution Control Center
            </h1>
            <p style={{ color: 'var(--text-secondary)', fontSize: '0.95rem', maxWidth: '600px' }}>
              "{focusText}"
            </p>
          </div>

          {/* Quick Metrics Bar */}
          <div style={{ display: 'flex', gap: '1rem', flexWrap: 'wrap' }}>
            <div style={{
              backgroundColor: 'var(--card-elevated)',
              border: '1px solid var(--border-color)',
              borderRadius: 'var(--radius-md)',
              padding: '0.85rem 1.25rem',
              minWidth: '120px'
            }}>
              <span style={{ fontSize: '0.75rem', color: 'var(--text-tertiary)', textTransform: 'uppercase', fontWeight: '700' }}>
                Score
              </span>
              <div style={{ fontSize: '1.6rem', fontWeight: '800', color: 'var(--accent-lime)' }}>
                {executionScore}%
              </div>
            </div>

            <div style={{
              backgroundColor: 'var(--card-elevated)',
              border: '1px solid var(--border-color)',
              borderRadius: 'var(--radius-md)',
              padding: '0.85rem 1.25rem',
              minWidth: '130px'
            }}>
              <span style={{ fontSize: '0.75rem', color: 'var(--text-tertiary)', textTransform: 'uppercase', fontWeight: '700' }}>
                Time Executed
              </span>
              <div style={{ fontSize: '1.6rem', fontWeight: '800', color: 'var(--text-primary)' }}>
                {completedEstMins}m <span style={{ fontSize: '0.85rem', color: 'var(--text-tertiary)', fontWeight: '400' }}>/ {totalEstMins}m</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Main Grid: Tasks + Habits */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(340px, 1fr))', gap: '1.5rem' }}>

        {/* Today's Tasks Column */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <h2 style={{ fontSize: '1.25rem', fontWeight: '700', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
              <CheckCircle2 size={20} style={{ color: 'var(--accent-lime)' }} />
              <span>Today's Action Items</span>
            </h2>
            <button className="btn btn-ghost" onClick={() => setCreateModalType('task')}>
              <Plus size={16} />
              <span>Add Task</span>
            </button>
          </div>

          {todayTasks.length === 0 ? (
            <div className="ordin-card" style={{ textAlign: 'center', padding: '2.5rem', color: 'var(--text-tertiary)' }}>
              No tasks scheduled for today yet.
            </div>
          ) : (
            todayTasks.map(task => {
              const colorBadge = getLifeAreaColor(task.category);
              return (
                <div
                  key={task.id}
                  className="ordin-card interactive"
                  style={{
                    opacity: task.completed ? 0.65 : 1,
                    borderColor: task.completed ? 'transparent' : undefined
                  }}
                >
                  <div style={{ display: 'flex', alignItems: 'flex-start', gap: '0.85rem' }}>
                    <div
                      className={`checkbox-custom ${task.completed ? 'checked' : ''}`}
                      onClick={() => toggleTask(task.id)}
                      style={{ marginTop: '2px' }}
                    >
                      {task.completed && <CheckCircle2 size={16} />}
                    </div>

                    <div style={{ flex: 1 }}>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', marginBottom: '0.25rem' }}>
                        <span className={`badge badge-${colorBadge}`}>{task.category}</span>
                        {task.priority === 'high' && <span className="badge badge-red">High Priority</span>}
                        <span style={{ fontSize: '0.75rem', color: 'var(--text-tertiary)', marginLeft: 'auto', display: 'flex', alignItems: 'center', gap: '0.25rem' }}>
                          <Clock size={12} /> {task.estimatedMinutes}m
                        </span>
                      </div>

                      <div style={{
                        fontSize: '1rem',
                        fontWeight: '600',
                        textDecoration: task.completed ? 'line-through' : 'none',
                        color: task.completed ? 'var(--text-tertiary)' : 'var(--text-primary)'
                      }}>
                        {task.title}
                      </div>

                      {/* Subtasks listing if available */}
                      {task.subtasks && task.subtasks.length > 0 && (
                        <div style={{ marginTop: '0.75rem', display: 'flex', flexDirection: 'column', gap: '0.35rem', paddingLeft: '0.5rem', borderLeft: '2px solid var(--border-color)' }}>
                          {task.subtasks.map(st => (
                            <div
                              key={st.id}
                              onClick={() => toggleSubtask(task.id, st.id)}
                              style={{
                                display: 'flex',
                                alignItems: 'center',
                                gap: '0.5rem',
                                fontSize: '0.82rem',
                                color: st.completed ? 'var(--text-tertiary)' : 'var(--text-secondary)',
                                cursor: 'pointer',
                                textDecoration: st.completed ? 'line-through' : 'none'
                              }}
                            >
                              <div className={`checkbox-custom ${st.completed ? 'checked' : ''}`} style={{ width: '14px', height: '14px' }}>
                                {st.completed && <CheckCircle2 size={10} />}
                              </div>
                              <span>{st.title}</span>
                            </div>
                          ))}
                        </div>
                      )}
                    </div>

                    {/* Action buttons */}
                    <div style={{ display: 'flex', gap: '0.25rem' }}>
                      <button className="btn-icon" onClick={() => openTimerWithTask(task)} title="Focus Timer for this Task">
                        <Timer size={16} style={{ color: 'var(--accent-lime)' }} />
                      </button>
                      <button className="btn-icon" onClick={() => deleteTask(task.id)} title="Delete Task">
                        <Trash2 size={16} />
                      </button>
                    </div>
                  </div>
                </div>
              );
            })
          )}
        </div>

        {/* Daily Habits Matrix Column */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <h2 style={{ fontSize: '1.25rem', fontWeight: '700', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
              <Flame size={20} style={{ color: 'var(--orange)' }} />
              <span>Habit Streaks</span>
            </h2>
            <button className="btn btn-ghost" onClick={() => setCreateModalType('habit')}>
              <Plus size={16} />
              <span>Add Habit</span>
            </button>
          </div>

          {habits.map(habit => {
            const isDoneToday = habit.completedDates.includes(todayStr);
            const colorBadge = getLifeAreaColor(habit.category);

            return (
              <div
                key={habit.id}
                className="ordin-card interactive"
                style={{
                  borderColor: isDoneToday ? 'var(--orange)' : undefined
                }}
              >
                <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '0.85rem' }}>
                    <div
                      className={`checkbox-custom ${isDoneToday ? 'checked' : ''}`}
                      onClick={() => toggleHabitToday(habit.id)}
                      style={{
                        backgroundColor: isDoneToday ? 'var(--orange)' : 'transparent',
                        borderColor: isDoneToday ? 'var(--orange)' : undefined
                      }}
                    >
                      {isDoneToday && <CheckCircle2 size={16} style={{ color: 'var(--text-on-lime)' }} />}
                    </div>

                    <div>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '0.4rem', marginBottom: '0.2rem' }}>
                        <span className={`badge badge-${colorBadge}`}>{habit.category}</span>
                      </div>
                      <div style={{ fontWeight: '600', fontSize: '0.95rem' }}>
                        {habit.title}
                      </div>
                    </div>
                  </div>

                  {/* Streak Count Badge */}
                  <div style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: '0.35rem',
                    backgroundColor: 'var(--orange-glow)',
                    border: '1px solid var(--border-color)',
                    color: 'var(--orange)',
                    padding: '0.4rem 0.75rem',
                    borderRadius: 'var(--radius-full)',
                    fontWeight: '700',
                    fontSize: '0.85rem'
                  }}>
                    <Flame size={16} />
                    <span>{habit.streak}d streak</span>
                  </div>
                </div>
              </div>
            );
          })}
        </div>

      </div>
    </div>
  );
}
