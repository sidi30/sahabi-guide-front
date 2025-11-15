import { useEffect } from 'react';
import Header from './components/Header';
import Footer from './components/Footer';
import Home from './pages/Home';
import useScrollToHash from './hooks/useScrollToHash';

export default function App() {
  useScrollToHash();

  // Ensure we start at top (no hash)
  useEffect(() => {
    if (!location.hash) window.scrollTo(0, 0);
  }, []);

  return (
    <div className="min-h-screen flex flex-col bg-white">
      <Header />
      <main className="flex-1">
        <Home />
      </main>
      <Footer />
    </div>
  );
}


