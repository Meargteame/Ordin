import React, { useState } from 'react';
import { Calendar, Plus, Clock, CheckCircle2 } from 'lucide-react';
import { useApp } from '../context/AppContext';

export default function CalendarView() {
  const { timeBlocks, toggleTimeBlock, addTimeBlock, lifeAreas } = useApp();

  const [title, setTitle] = useState('');
  const [startTime, setStartTime] = useState('09:00');
  const [endTime, setEndTime] = useState('10:00');
  const [category, setCategory] = useState('career');

  const handleAdd = (e) => {
    e.preventDefault();
    if (!title.trim()) return;
    addTimeBlock({ title, startTime, endTime, category });
    setTitle('');
  };

  const getLifeAreaColor = (catId) => {
    const area = lifeAreas.find(a => a.id === catId);
    return area ? area.color : 'lime';
  };

  return (
    <div className="page-view">
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '1.75rem', flexWrap: 'wrap', gap: '1rem' }}>
        <div>
          <h1 style={{ fontSize: '1.8rem', fontWeight: '800', display: 'flex', alignItems: 'center', gap: '0.6rem' }}>
            <Calendar size={26} style={{ color: 'var(--accent-lime)' }} />
            <span>Time Blocking Scheduler</span>
          </h1>
          <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem' }}>
            Schedule focused daily execution slots to protect uninterrupted deep work
          </p>
        </div>
      </div>

      {/* Add Time Block Form */}
      <div className="ordin-card" style={{ marginBottom: '1.5rem', padding: '1.25rem' }}>
        <h3 style={{ fontSize: '1rem', fontWeight: '700', marginBottom: '1rem' }}>Add Focus Time Block</h3>
        <form onSubmit={handleAdd} style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(180px, 1fr))', gap: '1rem', alignItems: 'end' }}>
          <div className="input-group" style={{ marginBottom: 0 }}>
            <label className="input-label">Slot Name</label>
            <input
              type="text"
              className="ordin-input"
              placeholder="e.g. Deep Work: Web MVP"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              required
            />
          </div>

          <div className="input-group" style={{ marginBottom: 0 }}>
            <label className="input-label">Start Time</label>
            <input
              type="time"
              className="ordin-input"
              value={startTime}
              onChange={(e) => setStartTime(e.target.value)}
            />
          </div>

          <div className="input-group" style={{ marginBottom: 0 }}>
            <label className="input-label">End Time</label>
            <input
              type="time"
              className="ordin-input"
              value={endTime}
              onChange={(e) => setEndTime(e.target.value)}
            />
          </div>

          <div className="input-group" style={{ marginBottom: 0 }}>
            <label className="input-label">Category</label>
            <select
              className="ordin-input"
              value={category}
              onChange={(e) => setCategory(e.target.value)}
            >
              {lifeAreas.map(la => (
                <option key={la.id} value={la.id}>{la.name}</option>
              ))}
            </select>
          </div>

          <button type="submit" className="btn btn-primary" style={{ padding: '0.75rem' }}>
            <Plus size={16} />
            <span>Add Slot</span>
          </button>
        </form>
      </div>

      {/* Time Blocks Timeline */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
        {timeBlocks.map(block => {
          const colorBadge = getLifeAreaColor(block.category);
          return (
            <div 
              key={block.id} 
              className="ordin-card interactive"
              onClick={() => toggleTimeBlock(block.id)}
              style={{
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
                opacity: block.completed ? 0.65 : 1
              }}
            >
              <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
                <div className={`checkbox-custom ${block.completed ? 'checked' : ''}`}>
                  {block.completed && <CheckCircle2 size={16} />}
                </div>

                <div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '0.4rem', marginBottom: '0.2rem' }}>
                    <span className={`badge badge-${colorBadge}`}>{block.category}</span>
                    <span style={{ fontSize: '0.8rem', color: 'var(--accent-lime)', fontWeight: '700', fontFamily: 'var(--font-mono)' }}>
                      {block.startTime} — {block.endTime}
                    </span>
                  </div>
                  <div style={{ fontWeight: '600', fontSize: '1rem', textDecoration: block.completed ? 'line-through' : 'none' }}>
                    {block.title}
                  </div>
                </div>
              </div>

              <span style={{ fontSize: '0.85rem', color: 'var(--text-tertiary)' }}>
                {block.completed ? 'Completed' : 'Scheduled'}
              </span>
            </div>
          );
        })}
      </div>
    </div>
  );
}
