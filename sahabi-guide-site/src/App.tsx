import { Routes, Route } from 'react-router-dom'
import Home from './pages/Home'
import Header from './components/Header'
import Footer from './components/Footer'
import ScrollToTop from './components/ScrollToTop'
import { useScrollToHash } from './hooks/useScrollToHash'

function App() {
  useScrollToHash()

  return (
    <div className="min-h-screen flex flex-col overflow-x-hidden">
      <Header />
      <main className="flex-1 w-full overflow-x-hidden">
        <Routes>
          <Route path="/" element={<Home />} />
        </Routes>
      </main>
      <Footer />
      <ScrollToTop />
    </div>
  )
}

export default App
