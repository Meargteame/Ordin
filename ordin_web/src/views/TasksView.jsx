import React, { useState } from 'react';
import { 
  CheckSquare, 
  Plus, 
  Search, 
  Filter, 
  Trash2, 
  Timer, 
  CheckCircle2, 
  Clock, 
  AlertCircle 
} from 'lucide-react';
import { useApp } from '../context/AppContext';

export default function TasksView() {
  const { 
    tasks, 
    toggleTask, 
    deleteTask, 
    toggleSubtask, 
    openTimerWithTask, 
    setCreateModalType, 
    lifeAreas 
  } = useApp();

  const [filterCategory, setFilterCategory] = useState('all');
  const [filterPriority, setFilterPriority] = useState('all');
  const [searchQuery, setSearchQuery] = useState('');

  const filteredTasks = tasks.filter(t => {
    if (filterCategory !== 'all' && t.category !== filterCategory) return false;
    if (filterPriority !== 'all' && t.priority !== filterPriority) return false;
    if (searchQuery.trim() && !t.title.toLowerCase().includes(searchQuery.toLowerCase())) return false;
    return true;
  });

  const getLifeAreaColor = (catId) => {
    const area = lifeAreas.find(a => a.id === catId);
    return area ? area.color : 'lime';
  };

  return (
    <div className="page-view">
      {/* Header */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '1.75rem', flexWrap: 'wrap', gap: '1rem' }}>
        <div>
          <h1 style={{ fontSize: '1.8rem', fontWeight: '800', display: 'flex', alignItems: 'center', gap: '0.6rem' }}>
            <CheckSquare size={26} style={{ color: 'var(--accent-lime)' }} />
            <span>Tasks System</span>
          </h1>
          <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem' }}>
            Organize, prioritize, and complete your actionable daily tasks
          </p>
        </div>

        <button className="btn btn-primary" onClick={() => setCreateModalType('task')}>
          <Plus size={18} />
          <span>New Task</span>
        </button>
      </div>

      {/* Filter & Search Toolbar */}
      <div className="ordin-card" style={{ padding: '1rem', marginBottom: '1.5rem', display: 'flex', alignItems: 'center', gap: '1rem', flexWrap: 'wrap' }}>
        {/* Search */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', flex: 1, minWidth: '220px', backgroundColor: 'rgba(255,255,255,0.04)', border: '1px solid var(--border-color)', borderRadius: 'var(--radius-sm)', padding: '0.5rem 0.8rem' }}>
          <Search size={16} style={{ color: 'var(--text-tertiary)' }} />
          <input
            type="text"
            placeholder="Search tasks..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            style={{ background: 'transparent', border: 'none', color: 'var(--text-primary)', width: '100%', fontSize: '0.9rem' }}
          />
        </div>

        {/* Filter Category */}
        <select
          className="ordin-input"
          style={{ width: 'auto', minWidth: '160px', padding: '0.55rem 0.8rem' }}
          value={filterCategory}
          onChange={(e) => setFilterCategory(e.target.value)}
        >
          <option value="all">All Categories</option>
          {lifeAreas.map(la => (
            <option key={la.id} value={la.id}>{la.name}</option>
          ))}
        </select>

        {/* Filter Priority */}
        <select
          className="ordin-input"
          style={{ width: 'auto', minWidth: '150px', padding: '0.55rem 0.8rem' }}
          value={filterPriority}
          onChange={(e) => setFilterPriority(e.target.value)}
        >
          <option value="all">All Priorities</option>
          <option value="high">High Priority</option>
          <option value="medium">Medium Priority</option>
          <option value="low">Low Priority</option>
        </select>
      </div>

      {/* Task List */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: '0.85rem' }}>
        {filteredTasks.length === 0 ? (
          <div className="ordin-card" style={{ textAlign: 'center', padding: '3rem', color: 'var(--text-tertiary)' }}>
            No tasks match your filters.
          </div>
        ) : (
          filteredTasks.map(t => {
            const badgeColor = getLifeAreaColor(t.category);
            return (
              <div 
                key={t.id} 
                className="ordin-card interactive"
                style={{
                  opacity: t.completed ? 0.6 : 1,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  gap: '1rem',
                  flexWrap: 'wrap'
                }}
              >
                <div style={{ display: 'flex', alignItems: 'center', gap: '0.85rem', flex: 1, minWidth: '260px' }}>
                  <div 
                    className={`checkbox-custom ${t.completed ? 'checked' : ''}`}
                    onClick={() => toggleTask(t.id)}
                  >
                    {t.completed && <CheckCircle2 size={16} />}
                  </div>

                  <div>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '0.4rem', marginBottom: '0.2rem' }}>
                      <span className={`badge badge-${badgeColor}`}>{t.category}</span>
                      {t.priority === 'high' && <span className="badge badge-red">High Priority</span>}
                    </div>

                    <div style={{
                      fontSize: '1rem',
                      fontWeight: '600',
                      textDecoration: t.completed ? 'line-through' : 'none'
                    }}>
                      {t.title}
                    </div>
                  </div>
                </div>

                <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
                  <span style={{ fontSize: '0.8rem', color: 'var(--text-tertiary)', display: 'flex', alignItems: 'center', gap: '0.25rem' }}>
                    <Clock size={14} /> {t.estimatedMinutes}m
                  </span>

                  <button className="btn-icon" onClick={() => openTimerWithTask(t)} title="Focus Timer">
                    <Timer size={16} style={{ color: 'var(--accent-lime)' }} />
                  </button>

                  <button className="btn-icon" onClick={() => deleteTask(t.id)} title="Delete Task">
                    <Trash2 size={16} />
                  </button>
                </div>
              </div>
            );
          })
        )}
      </div>
    </div>
  );
}
