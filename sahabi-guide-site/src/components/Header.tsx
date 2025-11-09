import { useState } from 'react'
import { Link } from 'react-router-dom'
import { motion, AnimatePresence } from 'framer-motion'
import { Menu, X, Download } from 'lucide-react'
import CTAButton from './CTAButton'
import logoImage from '../assets/sahabi logo.png'

export default function Header() {
  const [isMenuOpen, setIsMenuOpen] = useState(false)

  const navLinks = [
    { label: 'Accueil', href: '/#accueil' },
    { label: 'Fonctionnalités', href: '/#fonctionnalites' },
    { label: 'Pour qui ?', href: '/#pour-qui' },
    { label: 'Assistant IA', href: '/#assistant' },
    { label: 'Bracelet', href: '/#bracelet' },
    { label: 'Agences', href: '/#agences' },
    { label: 'FAQ', href: '/#faq' },
    { label: 'Contact', href: '/#contact' },
  ]

  return (
    <header className="fixed top-0 left-0 right-0 bg-white/95 backdrop-blur-sm shadow-md z-50 w-full">
      <div className="container mx-auto px-4 max-w-full">
        <div className="flex items-center justify-between h-20">
          {/* Logo */}
          <Link to="/" className="flex items-center space-x-3">
            <img 
              src={logoImage} 
              alt="SahabiGuide Logo" 
              className="h-12 w-auto object-contain"
            />
            <span className="text-xl font-bold text-gray-900 font-display">
              SahabiGuide
            </span>
          </Link>

          {/* Desktop Navigation */}
          <nav className="hidden lg:flex items-center space-x-6">
            {navLinks.map((link) => (
              <a
                key={link.href}
                href={link.href}
                className="text-gray-700 hover:text-primary-600 transition-colors duration-200 font-medium"
              >
                {link.label}
              </a>
            ))}
          </nav>

          {/* CTA Button */}
          <div className="hidden lg:block">
            <CTAButton href="/#telechargement" icon={Download} size="sm">
              Télécharger l'app
            </CTAButton>
          </div>

          {/* Mobile Menu Button */}
          <button
            onClick={() => setIsMenuOpen(!isMenuOpen)}
            className="lg:hidden p-2 rounded-lg hover:bg-gray-100 transition-colors"
            aria-label="Toggle menu"
          >
            {isMenuOpen ? (
              <X className="w-6 h-6 text-gray-900" />
            ) : (
              <Menu className="w-6 h-6 text-gray-900" />
            )}
          </button>
        </div>
      </div>

      {/* Mobile Menu */}
      <AnimatePresence>
        {isMenuOpen && (
          <motion.div
            initial={{ opacity: 0, height: 0 }}
            animate={{ opacity: 1, height: 'auto' }}
            exit={{ opacity: 0, height: 0 }}
            className="lg:hidden bg-white border-t border-gray-200 overflow-hidden"
          >
            <nav className="container mx-auto px-4 py-6 flex flex-col space-y-4">
              {navLinks.map((link) => (
                <a
                  key={link.href}
                  href={link.href}
                  onClick={() => setIsMenuOpen(false)}
                  className="text-gray-700 hover:text-primary-600 transition-colors duration-200 font-medium py-2"
                >
                  {link.label}
                </a>
              ))}
              <CTAButton href="/#telechargement" icon={Download} size="sm" className="w-full">
                Télécharger l'app
              </CTAButton>
            </nav>
          </motion.div>
        )}
      </AnimatePresence>
    </header>
  )
}

