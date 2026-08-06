import React from 'react';
import { FolderKanban, Plus, CheckCircle2, Clock } from 'lucide-react';
import { useApp } from '../context/AppContext';

export default function ProjectsView() {
  const { projects, setCreateModalType, lifeAreas } = useApp();

  const getLifeAreaColor = (catId) => {
    const area = lifeAreas.find(a => a.id === catId);
    return area ? area.color : 'blue';
  };

  return (
    <div className="page-view">
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '1.75rem', flexWrap: 'wrap', gap: '1rem' }}>
        <div>
          <h1 style={{ fontSize: '1.8rem', fontWeight: '800', display: 'flex', alignItems: 'center', gap: '0.6rem' }}>
            <FolderKanban size={26} style={{ color: 'var(--blue)' }} />
            <span>Projects Board</span>
          </h1>
          <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem' }}>
            Multi-stage initiative tracking and deliverables
          </p>
        </div>

        <button className="btn btn-primary" onClick={() => setCreateModalType('project')}>
          <Plus size={18} />
          <span>New Project</span>
        </button>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))', gap: '1.5rem' }}>
        {projects.map(proj => {
          const colorBadge = getLifeAreaColor(proj.category);
          return (
            <div key={proj.id} className="ordin-card interactive" style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                <span className={`badge badge-${colorBadge}`}>{proj.category}</span>
                <span className="badge badge-lime">{proj.status}</span>
              </div>

              <div>
                <h3 style={{ fontSize: '1.2rem', fontWeight: '700', marginBottom: '0.3rem' }}>{proj.title}</h3>
                <p style={{ color: 'var(--text-secondary)', fontSize: '0.85rem' }}>{proj.description}</p>
              </div>

              <div>
                <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.8rem', marginBottom: '0.3rem' }}>
                  <span>Completion</span>
                  <span style={{ color: 'var(--accent-lime)', fontWeight: '700' }}>{proj.progress}%</span>
                </div>
                <div style={{ width: '100%', height: '8px', backgroundColor: 'rgba(255,255,255,0.08)', borderRadius: '10px', overflow: 'hidden' }}>
                  <div style={{ width: `${proj.progress}%`, height: '100%', backgroundColor: 'var(--blue)', transition: 'width 0.3s' }} />
                </div>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
