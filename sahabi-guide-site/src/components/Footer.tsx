import { Link } from 'react-router-dom'
import { Mail, MapPin } from 'lucide-react'
import logoImage from '../assets/sahabi logo.png'

export default function Footer() {
  const quickLinks = [
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
    <footer className="bg-gray-900 text-white pt-16 pb-8">
      <div className="container mx-auto px-4">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8 mb-12">
          {/* Logo & Description */}
          <div className="lg:col-span-2">
            <Link to="/" className="flex items-center space-x-3 mb-4">
              <img 
                src={logoImage} 
                alt="SahabiGuide Logo" 
                className="h-10 w-auto object-contain"
              />
              <span className="text-xl font-bold font-display">
                SahabiGuide
              </span>
            </Link>
            <p className="text-gray-400 mb-4 max-w-md">
              Votre compagnon numérique pour un Hadj serein et connecté. Une solution complète 
              pour accompagner les pèlerins avant, pendant et après leur voyage sacré.
            </p>
            <div className="flex flex-col space-y-2 text-gray-400">
              <div className="flex items-center space-x-2">
                <MapPin className="w-4 h-4" />
                <span>Niamey, Niger</span>
              </div>
              <div className="flex items-center space-x-2">
                <Mail className="w-4 h-4" />
                <a href="mailto:contact@sahabiguide.com" className="hover:text-primary-400 transition-colors">
                  contact@sahabiguide.com
                </a>
              </div>
            </div>
          </div>

          {/* Quick Links */}
          <div>
            <h3 className="text-lg font-bold mb-4">Liens rapides</h3>
            <ul className="space-y-2">
              {quickLinks.slice(0, 4).map((link) => (
                <li key={link.href}>
                  <a
                    href={link.href}
                    className="text-gray-400 hover:text-primary-400 transition-colors"
                  >
                    {link.label}
                  </a>
                </li>
              ))}
            </ul>
          </div>

          {/* More Links */}
          <div>
            <h3 className="text-lg font-bold mb-4">Plus d'infos</h3>
            <ul className="space-y-2">
              {quickLinks.slice(4).map((link) => (
                <li key={link.href}>
                  <a
                    href={link.href}
                    className="text-gray-400 hover:text-primary-400 transition-colors"
                  >
                    {link.label}
                  </a>
                </li>
              ))}
            </ul>
          </div>
        </div>

        {/* Bottom Bar */}
        <div className="border-t border-gray-800 pt-8 flex flex-col md:flex-row justify-between items-center space-y-4 md:space-y-0">
          <p className="text-gray-400 text-sm">
            © {new Date().getFullYear()} SahabiGuide. Tous droits réservés.
          </p>
          <div className="flex space-x-6 text-sm text-gray-400">
            <a href="/#contact" className="hover:text-primary-400 transition-colors">
              Politique de confidentialité
            </a>
            <a href="/#contact" className="hover:text-primary-400 transition-colors">
              Conditions d'utilisation
            </a>
          </div>
        </div>
      </div>
    </footer>
  )
}

