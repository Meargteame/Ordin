import React, { useState } from 'react';
import { X, Plus, Sparkles } from 'lucide-react';
import { useApp } from '../context/AppContext';

export default function CreateModal() {
  const { 
    createModalType, 
    setCreateModalType, 
    addTask, 
    addHabit, 
    addGoal, 
    addProject, 
    addNote,
    lifeAreas
  } = useApp();

  // Task Form State
  const [taskTitle, setTaskTitle] = useState('');
  const [taskCategory, setTaskCategory] = useState('career');
  const [taskPriority, setTaskPriority] = useState('medium');
  const [taskEst, setTaskEst] = useState(30);

  // Habit Form State
  const [habitTitle, setHabitTitle] = useState('');
  const [habitCategory, setHabitCategory] = useState('health');

  // Goal Form State
  const [goalTitle, setGoalTitle] = useState('');
  const [goalLifeArea, setGoalLifeArea] = useState('career');

  // Project Form State
  const [projTitle, setProjTitle] = useState('');
  const [projDesc, setProjDesc] = useState('');

  // Note Form State
  const [noteTitle, setNoteTitle] = useState('');
  const [noteContent, setNoteContent] = useState('');

  if (!createModalType) return null;

  const handleClose = () => setCreateModalType(null);

  const handleSubmit = (e) => {
    e.preventDefault();
    if (createModalType === 'task') {
      if (!taskTitle.trim()) return;
      addTask({
        title: taskTitle,
        category: taskCategory,
        priority: taskPriority,
        estimatedMinutes: Number(taskEst)
      });
      setTaskTitle('');
    } else if (createModalType === 'habit') {
      if (!habitTitle.trim()) return;
      addHabit({
        title: habitTitle,
        category: habitCategory
      });
      setHabitTitle('');
    } else if (createModalType === 'goal') {
      if (!goalTitle.trim()) return;
      addGoal({
        title: goalTitle,
        lifeArea: goalLifeArea
      });
      setGoalTitle('');
    } else if (createModalType === 'project') {
      if (!projTitle.trim()) return;
      addProject({
        title: projTitle,
        description: projDesc
      });
      setProjTitle('');
      setProjDesc('');
    } else if (createModalType === 'note') {
      if (!noteTitle.trim()) return;
      addNote({
        title: noteTitle,
        content: noteContent
      });
      setNoteTitle('');
      setNoteContent('');
    }
    handleClose();
  };

  const getTitle = () => {
    switch(createModalType) {
      case 'task': return 'Create New Task';
      case 'habit': return 'Build New Habit';
      case 'goal': return 'Define OKR Goal';
      case 'project': return 'Start New Project';
      case 'note': return 'Create Note';
      default: return 'Create Item';
    }
  };

  return (
    <div className="modal-overlay" onClick={handleClose}>
      <div className="modal-card" onClick={(e) => e.stopPropagation()} style={{ maxWidth: '480px' }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '1.5rem' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
            <Sparkles size={18} style={{ color: 'var(--accent-lime)' }} />
            <h3 style={{ fontSize: '1.2rem', fontWeight: '700' }}>{getTitle()}</h3>
          </div>
          <button className="btn-icon" onClick={handleClose}><X size={18} /></button>
        </div>

        <form onSubmit={handleSubmit}>
          {/* TASK FORM */}
          {createModalType === 'task' && (
            <>
              <div className="input-group">
                <label className="input-label">Task Title</label>
                <input
                  type="text"
                  className="ordin-input"
                  placeholder="What needs to get done?"
                  value={taskTitle}
                  onChange={(e) => setTaskTitle(e.target.value)}
                  autoFocus
                  required
                />
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem' }}>
                <div className="input-group">
                  <label className="input-label">Category</label>
                  <select
                    className="ordin-input"
                    value={taskCategory}
                    onChange={(e) => setTaskCategory(e.target.value)}
                  >
                    {lifeAreas.map(la => (
                      <option key={la.id} value={la.id}>{la.name}</option>
                    ))}
                  </select>
                </div>

                <div className="input-group">
                  <label className="input-label">Priority</label>
                  <select
                    className="ordin-input"
                    value={taskPriority}
                    onChange={(e) => setTaskPriority(e.target.value)}
                  >
                    <option value="high">High Priority</option>
                    <option value="medium">Medium Priority</option>
                    <option value="low">Low Priority</option>
                  </select>
                </div>
              </div>

              <div className="input-group">
                <label className="input-label">Est. Duration (Minutes)</label>
                <input
                  type="number"
                  className="ordin-input"
                  value={taskEst}
                  onChange={(e) => setTaskEst(e.target.value)}
                  min="5"
                  max="480"
                />
              </div>
            </>
          )}

          {/* HABIT FORM */}
          {createModalType === 'habit' && (
            <>
              <div className="input-group">
                <label className="input-label">Habit Name</label>
                <input
                  type="text"
                  className="ordin-input"
                  placeholder="e.g. Daily 30m Deep Work Block"
                  value={habitTitle}
                  onChange={(e) => setHabitTitle(e.target.value)}
                  autoFocus
                  required
                />
              </div>

              <div className="input-group">
                <label className="input-label">Life Area Category</label>
                <select
                  className="ordin-input"
                  value={habitCategory}
                  onChange={(e) => setHabitCategory(e.target.value)}
                >
                  {lifeAreas.map(la => (
                    <option key={la.id} value={la.id}>{la.name}</option>
                  ))}
                </select>
              </div>
            </>
          )}

          {/* GOAL FORM */}
          {createModalType === 'goal' && (
            <>
              <div className="input-group">
                <label className="input-label">Goal Title</label>
                <input
                  type="text"
                  className="ordin-input"
                  placeholder="Strategic Objective..."
                  value={goalTitle}
                  onChange={(e) => setGoalTitle(e.target.value)}
                  autoFocus
                  required
                />
              </div>

              <div className="input-group">
                <label className="input-label">Life Area</label>
                <select
                  className="ordin-input"
                  value={goalLifeArea}
                  onChange={(e) => setGoalLifeArea(e.target.value)}
                >
                  {lifeAreas.map(la => (
                    <option key={la.id} value={la.id}>{la.name}</option>
                  ))}
                </select>
              </div>
            </>
          )}

          {/* PROJECT FORM */}
          {createModalType === 'project' && (
            <>
              <div className="input-group">
                <label className="input-label">Project Name</label>
                <input
                  type="text"
                  className="ordin-input"
                  placeholder="Project Name"
                  value={projTitle}
                  onChange={(e) => setProjTitle(e.target.value)}
                  autoFocus
                  required
                />
              </div>

              <div className="input-group">
                <label className="input-label">Description</label>
                <textarea
                  className="ordin-input"
                  rows="3"
                  placeholder="Key goals & scope..."
                  value={projDesc}
                  onChange={(e) => setProjDesc(e.target.value)}
                />
              </div>
            </>
          )}

          {/* NOTE FORM */}
          {createModalType === 'note' && (
            <>
              <div className="input-group">
                <label className="input-label">Note Title</label>
                <input
                  type="text"
                  className="ordin-input"
                  placeholder="Note Title"
                  value={noteTitle}
                  onChange={(e) => setNoteTitle(e.target.value)}
                  autoFocus
                  required
                />
              </div>

              <div className="input-group">
                <label className="input-label">Content</label>
                <textarea
                  className="ordin-input"
                  rows="4"
                  placeholder="Write your note content here..."
                  value={noteContent}
                  onChange={(e) => setNoteContent(e.target.value)}
                />
              </div>
            </>
          )}

          <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '0.75rem', marginTop: '1.5rem' }}>
            <button type="button" className="btn btn-secondary" onClick={handleClose}>
              Cancel
            </button>
            <button type="submit" className="btn btn-primary">
              <Plus size={16} />
              <span>Create</span>
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
