import React, { useState, useEffect } from 'react';
import { X, Play, Pause, RotateCcw, CheckCircle, Volume2, VolumeX, Sparkles } from 'lucide-react';
import { useApp } from '../context/AppContext';

export default function FocusTimerModal() {
  const { isTimerOpen, setIsTimerOpen, activeTimerTask, toggleTask } = useApp();

  const [mode, setMode] = useState('pomodoro'); // 'pomodoro' (25m), 'deep' (50m), 'stopwatch'
  const [timeLeft, setTimeLeft] = useState(25 * 60);
  const [isRunning, setIsRunning] = useState(false);
  const [soundEnabled, setSoundEnabled] = useState(false);

  useEffect(() => {
    if (mode === 'pomodoro') setTimeLeft(25 * 60);
    else if (mode === 'deep') setTimeLeft(50 * 60);
    else if (mode === 'stopwatch') setTimeLeft(0);
    setIsRunning(false);
  }, [mode]);

  useEffect(() => {
    let interval = null;
    if (isRunning) {
      interval = setInterval(() => {
        setTimeLeft(prev => {
          if (mode === 'stopwatch') return prev + 1;
          if (prev <= 1) {
            setIsRunning(false);
            return 0;
          }
          return prev - 1;
        });
      }, 1000);
    } else {
      clearInterval(interval);
    }
    return () => clearInterval(interval);
  }, [isRunning, mode]);

  if (!isTimerOpen) return null;

  const formatTime = (seconds) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  };

  const initialSecs = mode === 'pomodoro' ? 25 * 60 : mode === 'deep' ? 50 * 60 : 60 * 60;
  const progressPct = mode === 'stopwatch' 
    ? 100 
    : Math.min(100, Math.round(((initialSecs - timeLeft) / initialSecs) * 100));

  return (
    <div className="modal-overlay" style={{ zIndex: 2000 }}>
      <div className="modal-card" style={{ maxWidth: '440px', textAlign: 'center', position: 'relative' }}>
        {/* Close Button */}
        <button
          className="btn-icon"
          onClick={() => setIsTimerOpen(false)}
          style={{ position: 'absolute', top: '1.25rem', right: '1.25rem' }}
        >
          <X size={20} />
        </button>

        {/* Header Title */}
        <div style={{ marginBottom: '1.5rem' }}>
          <span style={{ 
            fontSize: '0.75rem', 
            fontWeight: '700', 
            color: 'var(--accent-lime)',
            letterSpacing: '0.1em',
            textTransform: 'uppercase',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            gap: '0.35rem'
          }}>
            <Sparkles size={14} />
            Focus Session
          </span>
          <h2 style={{ fontSize: '1.4rem', fontWeight: '700', marginTop: '0.2rem' }}>
            {activeTimerTask ? activeTimerTask.title : 'Deep Focus Mode'}
          </h2>
        </div>

        {/* Mode Selector */}
        <div style={{
          display: 'flex',
          backgroundColor: 'rgba(255, 255, 255, 0.04)',
          border: '1px solid var(--border-color)',
          borderRadius: 'var(--radius-sm)',
          padding: '0.25rem',
          marginBottom: '2rem'
        }}>
          {[
            { id: 'pomodoro', label: '25m Pomodoro' },
            { id: 'deep', label: '50m Deep Work' },
            { id: 'stopwatch', label: 'Stopwatch' }
          ].map(m => (
            <button
              key={m.id}
              onClick={() => setMode(m.id)}
              style={{
                flex: 1,
                padding: '0.45rem',
                borderRadius: 'var(--radius-sm)',
                fontSize: '0.8rem',
                fontWeight: '600',
                color: mode === m.id ? 'var(--text-on-lime)' : 'var(--text-secondary)',
                backgroundColor: mode === m.id ? 'var(--accent-lime)' : 'transparent',
                transition: 'all var(--transition-fast)'
              }}
            >
              {m.label}
            </button>
          ))}
        </div>

        {/* Circular Visual & Digital Counter */}
        <div style={{
          position: 'relative',
          width: '200px',
          height: '200px',
          margin: '0 auto 2rem',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center'
        }}>
          <svg width="200" height="200" style={{ transform: 'rotate(-90deg)', position: 'absolute' }}>
            <circle
              cx="100"
              cy="100"
              r="85"
              stroke="rgba(255, 255, 255, 0.08)"
              strokeWidth="10"
              fill="transparent"
            />
            <circle
              cx="100"
              cy="100"
              r="85"
              stroke="var(--accent-lime)"
              strokeWidth="10"
              fill="transparent"
              strokeDasharray={2 * Math.PI * 85}
              strokeDashoffset={2 * Math.PI * 85 * (1 - progressPct / 100)}
              strokeLinecap="round"
              style={{ transition: 'stroke-dashoffset 0.5s ease' }}
            />
          </svg>

          <div style={{ zIndex: 1 }}>
            <div style={{
              fontFamily: 'var(--font-mono)',
              fontSize: '2.8rem',
              fontWeight: '700',
              letterSpacing: '-0.02em'
            }}>
              {formatTime(timeLeft)}
            </div>
            <span style={{ fontSize: '0.75rem', color: 'var(--text-tertiary)' }}>
              {isRunning ? 'Session Active' : 'Paused'}
            </span>
          </div>
        </div>

        {/* Controls */}
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '1rem', marginBottom: '1.5rem' }}>
          <button
            className="btn btn-secondary"
            onClick={() => {
              setIsRunning(false);
              if (mode === 'pomodoro') setTimeLeft(25 * 60);
              else if (mode === 'deep') setTimeLeft(50 * 60);
              else setTimeLeft(0);
            }}
            title="Reset Timer"
          >
            <RotateCcw size={18} />
          </button>

          <button
            className="btn btn-primary"
            onClick={() => setIsRunning(!isRunning)}
            style={{ width: '130px', padding: '0.75rem' }}
          >
            {isRunning ? (
              <>
                <Pause size={18} />
                <span>Pause</span>
              </>
            ) : (
              <>
                <Play size={18} />
                <span>Start</span>
              </>
            )}
          </button>

          <button
            className="btn btn-secondary"
            onClick={() => setSoundEnabled(!soundEnabled)}
            title={soundEnabled ? 'Mute Ambient Audio' : 'Enable Ambient Audio'}
          >
            {soundEnabled ? <Volume2 size={18} style={{ color: 'var(--accent-lime)' }} /> : <VolumeX size={18} />}
          </button>
        </div>

        {/* Complete Task Option */}
        {activeTimerTask && (
          <button
            className="btn btn-ghost"
            onClick={() => {
              toggleTask(activeTimerTask.id);
              setIsTimerOpen(false);
            }}
            style={{ width: '100%', fontSize: '0.85rem', color: 'var(--accent-lime)' }}
          >
            <CheckCircle size={16} />
            <span>Mark "{activeTimerTask.title}" Completed</span>
          </button>
        )}
      </div>
    </div>
  );
}
