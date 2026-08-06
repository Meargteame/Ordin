import React, { useState } from 'react';
import { BookOpen, Smile, Frown, Meh, Plus, Trash2, Tag, Sparkles } from 'lucide-react';
import { useApp } from '../context/AppContext';

export default function JournalView() {
  const { journal, saveJournalEntry, notes, deleteNote, setCreateModalType } = useApp();

  const todayStr = new Date().toISOString().split('T')[0];
  const todayEntry = journal.find(j => j.date === todayStr) || { mood: 5, gratitude: '', reflections: '' };

  const [mood, setMood] = useState(todayEntry.mood || 5);
  const [gratitude, setGratitude] = useState(todayEntry.gratitude || '');
  const [reflections, setReflections] = useState(todayEntry.reflections || '');

  const handleSaveJournal = (e) => {
    e.preventDefault();
    saveJournalEntry({ mood, gratitude, reflections });
    alert('Journal reflection saved for today!');
  };

  return (
    <div className="page-view">
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '1.75rem', flexWrap: 'wrap', gap: '1rem' }}>
        <div>
          <h1 style={{ fontSize: '1.8rem', fontWeight: '800', display: 'flex', alignItems: 'center', gap: '0.6rem' }}>
            <BookOpen size={26} style={{ color: 'var(--purple)' }} />
            <span>Journal & Thinking Workspace</span>
          </h1>
          <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem' }}>
            Daily reflections, mood tracking, and strategic notes repository
          </p>
        </div>

        <button className="btn btn-primary" onClick={() => setCreateModalType('note')}>
          <Plus size={18} />
          <span>New Note</span>
        </button>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(340px, 1fr))', gap: '1.5rem' }}>
        
        {/* Daily Journal Reflection Form */}
        <div className="ordin-card" style={{ display: 'flex', flexDirection: 'column', gap: '1.25rem' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
            <Sparkles size={18} style={{ color: 'var(--accent-lime)' }} />
            <h2 style={{ fontSize: '1.2rem', fontWeight: '700' }}>Today's Reflection ({todayStr})</h2>
          </div>

          <form onSubmit={handleSaveJournal} style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
            {/* Mood Selector */}
            <div>
              <label className="input-label" style={{ marginBottom: '0.5rem', display: 'block' }}>Daily State / Energy</label>
              <div style={{ display: 'flex', gap: '0.75rem' }}>
                {[
                  { score: 1, label: 'Low', color: 'var(--red)' },
                  { score: 3, label: 'Medium', color: 'var(--orange)' },
                  { score: 5, label: 'Optimal', color: 'var(--accent-lime)' }
                ].map(m => (
                  <button
                    key={m.score}
                    type="button"
                    onClick={() => setMood(m.score)}
                    style={{
                      flex: 1,
                      padding: '0.6rem',
                      borderRadius: 'var(--radius-sm)',
                      border: mood === m.score ? `2px solid ${m.color}` : '1px solid var(--border-color)',
                      backgroundColor: mood === m.score ? 'rgba(255,255,255,0.06)' : 'transparent',
                      color: mood === m.score ? 'var(--text-primary)' : 'var(--text-secondary)',
                      fontWeight: '600',
                      fontSize: '0.85rem'
                    }}
                  >
                    {m.label}
                  </button>
                ))}
              </div>
            </div>

            <div className="input-group">
              <label className="input-label">Daily Gratitude</label>
              <input
                type="text"
                className="ordin-input"
                placeholder="What are you grateful for today?"
                value={gratitude}
                onChange={(e) => setGratitude(e.target.value)}
              />
            </div>

            <div className="input-group">
              <label className="input-label">Key Reflections & Wins</label>
              <textarea
                className="ordin-input"
                rows="4"
                placeholder="What went well? What could be improved tomorrow?"
                value={reflections}
                onChange={(e) => setReflections(e.target.value)}
              />
            </div>

            <button type="submit" className="btn btn-primary" style={{ alignSelf: 'flex-start' }}>
              Save Reflection
            </button>
          </form>
        </div>

        {/* Notes Repository Column */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
          <h2 style={{ fontSize: '1.2rem', fontWeight: '700' }}>Tagged Notes & Strategy</h2>

          {notes.map(note => (
            <div key={note.id} className="ordin-card interactive" style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem' }}>
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                <h3 style={{ fontSize: '1.1rem', fontWeight: '700' }}>{note.title}</h3>
                <button className="btn-icon" onClick={() => deleteNote(note.id)} title="Delete Note">
                  <Trash2 size={16} />
                </button>
              </div>

              <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem', whitespace: 'pre-line' }}>
                {note.content}
              </p>

              {note.tags && note.tags.length > 0 && (
                <div style={{ display: 'flex', gap: '0.4rem', flexWrap: 'wrap' }}>
                  {note.tags.map(tag => (
                    <span key={tag} className="badge badge-purple" style={{ fontSize: '0.7rem' }}>
                      <Tag size={10} /> #{tag}
                    </span>
                  ))}
                </div>
              )}
            </div>
          ))}
        </div>

      </div>
    </div>
  );
}
