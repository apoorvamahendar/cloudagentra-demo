import { useEffect, useState } from "react";

const API = process.env.REACT_APP_API_URL || "http://localhost:8000";

export default function App() {
  const [todos, setTodos] = useState([]);
  const [text, setText] = useState("");
  const [loading, setLoading] = useState(true);

  const load = async () => {
    try {
      const r = await fetch(`${API}/todos`);
      setTodos(await r.json());
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { load(); }, []);

  const add = async (e) => {
    e.preventDefault();
    if (!text.trim()) return;
    await fetch(`${API}/todos`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ text }),
    });
    setText("");
    load();
  };

  const remove = async (id) => {
    await fetch(`${API}/todos/${id}`, { method: "DELETE" });
    load();
  };

  return (
    <div className="wrap">
      <h1>Cloud Agentra Demo — Todos</h1>
      <form onSubmit={add}>
        <input
          value={text}
          onChange={(e) => setText(e.target.value)}
          placeholder="What needs doing?"
        />
        <button type="submit">Add</button>
      </form>
      {loading ? (
        <p className="hint">Loading…</p>
      ) : todos.length === 0 ? (
        <p className="hint">No todos yet — add one above.</p>
      ) : (
        <ul>
          {todos.map((t) => (
            <li key={t.id}>
              <span>{t.text}</span>
              <button onClick={() => remove(t.id)}>×</button>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
