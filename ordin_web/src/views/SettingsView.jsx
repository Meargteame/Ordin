import React from 'react';
import { Settings, Download, RefreshCw, Shield, Sun, Moon, Palette, Check } from 'lucide-react';
import { useApp } from '../context/AppContext';

export default function SettingsView() {
  const { theme, setTheme, exportAppData, resetAllStorage } = useApp();

  const themes = [
    {
      id: 'wood',
      name: 'Warm Wood & Tactile Gray',
      desc: 'Natural stone & muted wood tone light background. Non-glaring, tactile, and warm.',
      icon: Sun,
      color: '#D97706',
      bg: '#EAE6DF'
    },
    {
      id: 'dark',
      name: 'Dark Obsidian',
      desc: 'Sleek dark obsidian mode with electric lime accent highlights.',
      icon: Moon,
      color: '#D4FF00',
      bg: '#0F0F0F'
    },
    {
      id: 'slate',
      name: 'Nordic Slate Gray',
      desc: 'Cool slate gray light mode with indigo highlights.',
      icon: Palette,
      color: '#2563EB',
      bg: '#E2E8F0'
    }
  ];

  return (
    <div className="page-view" style={{ maxWidth: '800px' }}>
      <div style={{ marginBottom: '1.75rem' }}>
        <h1 style={{ fontSize: '1.8rem', fontWeight: '800', display: 'flex', alignItems: 'center', gap: '0.6rem' }}>
          <Settings size={26} style={{ color: 'var(--accent-lime)' }} />
          <span>System Settings & Preferences</span>
        </h1>
        <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem' }}>
          Customize your theme, manage local-first data storage, and exports
        </p>
      </div>

      <div style={{ display: 'flex', flexDirection: 'column', gap: '1.5rem' }}>
        
        {/* Theme Selector Card */}
        <div className="ordin-card" style={{ padding: '1.5rem' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.65rem', marginBottom: '0.5rem' }}>
            <Palette size={20} style={{ color: 'var(--accent-lime)' }} />
            <h2 style={{ fontSize: '1.2rem', fontWeight: '700' }}>Theme & Appearance</h2>
          </div>
          <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem', marginBottom: '1.25rem' }}>
            Select your preferred visual aesthetic for Ordin Web:
          </p>

          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', gap: '1rem' }}>
            {themes.map(t => {
              const Icon = t.icon;
              const isSelected = theme === t.id;
              return (
                <div
                  key={t.id}
                  onClick={() => setTheme(t.id)}
                  className="ordin-card interactive"
                  style={{
                    cursor: 'pointer',
                    borderColor: isSelected ? 'var(--accent-lime)' : undefined,
                    backgroundColor: isSelected ? 'var(--card-light)' : 'var(--card-dark)',
                    borderWidth: isSelected ? '2px' : '1px'
                  }}
                >
                  <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '0.75rem' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                      <div style={{
                        width: '24px',
                        height: '24px',
                        borderRadius: '50%',
                        backgroundColor: t.bg,
                        border: '1px solid rgba(0,0,0,0.1)',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center'
                      }}>
                        <Icon size={14} style={{ color: t.color }} />
                      </div>
                      <span style={{ fontWeight: '700', fontSize: '0.95rem' }}>{t.name}</span>
                    </div>
                    {isSelected && <Check size={18} style={{ color: 'var(--accent-lime)' }} />}
                  </div>
                  <p style={{ fontSize: '0.8rem', color: 'var(--text-secondary)' }}>{t.desc}</p>
                </div>
              );
            })}
          </div>
        </div>

        {/* Data Backup & Export Card */}
        <div className="ordin-card" style={{ padding: '1.5rem' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.65rem', marginBottom: '0.5rem' }}>
            <Download size={20} style={{ color: 'var(--accent-lime)' }} />
            <h2 style={{ fontSize: '1.2rem', fontWeight: '700' }}>Export & Backup Data</h2>
          </div>
          <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem', marginBottom: '1.25rem' }}>
            Export all your tasks, habits, goals, time blocks, and journal entries as a single JSON backup file.
          </p>

          <button className="btn btn-primary" onClick={exportAppData}>
            <Download size={16} />
            <span>Download JSON Backup</span>
          </button>
        </div>

        {/* Local Storage Privacy */}
        <div className="ordin-card" style={{ padding: '1.5rem' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.65rem', marginBottom: '0.5rem' }}>
            <Shield size={20} style={{ color: 'var(--green)' }} />
            <h2 style={{ fontSize: '1.2rem', fontWeight: '700' }}>Local-First Privacy Guarantee</h2>
          </div>
          <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem' }}>
            Ordin stores 100% of your operational data locally in your browser (`localStorage`). No cloud servers, no account required, no tracking. Fast, private, and lightweight.
          </p>
        </div>

        {/* Reset Storage Card */}
        <div className="ordin-card" style={{ padding: '1.5rem', borderColor: 'rgba(220, 38, 38, 0.3)' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.65rem', marginBottom: '0.5rem' }}>
            <RefreshCw size={20} style={{ color: 'var(--red)' }} />
            <h2 style={{ fontSize: '1.2rem', fontWeight: '700', color: 'var(--red)' }}>Reset Storage to Defaults</h2>
          </div>
          <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem', marginBottom: '1.25rem' }}>
            Reset all local tasks, habits, and goals back to initial seed data.
          </p>

          <button 
            className="btn" 
            onClick={() => {
              if (window.confirm('Are you sure you want to reset all data back to defaults?')) {
                resetAllStorage();
              }
            }}
            style={{ backgroundColor: 'var(--red-glow)', color: 'var(--red)', border: '1px solid rgba(220, 38, 38, 0.4)' }}
          >
            <RefreshCw size={16} />
            <span>Reset All Data</span>
          </button>
        </div>

      </div>
    </div>
  );
}
