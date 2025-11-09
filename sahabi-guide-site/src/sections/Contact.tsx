import { useState } from 'react'
import { motion } from 'framer-motion'
import { Send, Mail, MapPin, Phone } from 'lucide-react'
import SectionTitle from '../components/SectionTitle'

export default function Contact() {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    type: 'particulier',
    message: ''
  })
  const [isSubmitted, setIsSubmitted] = useState(false)

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    // Simulation d'envoi
    setIsSubmitted(true)
    setTimeout(() => {
      setIsSubmitted(false)
      setFormData({ name: '', email: '', type: 'particulier', message: '' })
    }, 3000)
  }

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value
    })
  }

  return (
    <section id="contact" className="py-12 md:py-16 lg:py-20 bg-gradient-to-br from-gray-50 to-primary-50">
      <div className="container mx-auto px-4">
        <SectionTitle
          title="Contactez-nous"
          subtitle="Une question ? Un projet ? Parlons-en ensemble"
        />
        
        <div className="mt-8 md:mt-12 lg:mt-16 grid lg:grid-cols-2 gap-8 md:gap-12 max-w-6xl mx-auto">
          {/* Contact Info */}
          <motion.div
            initial={{ opacity: 0, x: -30 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.6 }}
            className="space-y-8"
          >
            <div>
              <h3 className="text-2xl font-bold text-gray-900 mb-6">
                Restons en contact
              </h3>
              <p className="text-gray-600 leading-relaxed mb-8">
                Que vous soyez un pèlerin, une famille, une agence ou un investisseur, 
                nous sommes là pour répondre à toutes vos questions sur SahabiGuide.
              </p>
            </div>

            <div className="space-y-6">
              <div className="flex items-start space-x-4">
                <div className="flex-shrink-0 w-12 h-12 bg-primary-100 rounded-lg flex items-center justify-center">
                  <Mail className="w-6 h-6 text-primary-600" />
                </div>
                <div>
                  <h4 className="font-semibold text-gray-900 mb-1">Email</h4>
                  <a href="mailto:contact@sahabiguide.com" className="text-primary-600 hover:underline">
                    contact@sahabiguide.com
                  </a>
                </div>
              </div>

              <div className="flex items-start space-x-4">
                <div className="flex-shrink-0 w-12 h-12 bg-gold-100 rounded-lg flex items-center justify-center">
                  <Phone className="w-6 h-6 text-gold-600" />
                </div>
                <div>
                  <h4 className="font-semibold text-gray-900 mb-1">Téléphone</h4>
                  <a href="tel:+22712345678" className="text-gray-600 hover:text-primary-600">
                    +227 XX XX XX XX
                  </a>
                </div>
              </div>

              <div className="flex items-start space-x-4">
                <div className="flex-shrink-0 w-12 h-12 bg-primary-100 rounded-lg flex items-center justify-center">
                  <MapPin className="w-6 h-6 text-primary-600" />
                </div>
                <div>
                  <h4 className="font-semibold text-gray-900 mb-1">Adresse</h4>
                  <p className="text-gray-600">
                    Niamey, Niger<br />
                    Quartier d'affaires
                  </p>
                </div>
              </div>
            </div>

            <div className="pt-8 border-t border-gray-200">
              <h4 className="font-semibold text-gray-900 mb-4">Horaires d'ouverture</h4>
              <p className="text-gray-600">
                Lundi - Vendredi : 8h00 - 18h00<br />
                Samedi : 9h00 - 13h00<br />
                Dimanche : Fermé
              </p>
            </div>
          </motion.div>

          {/* Contact Form */}
          <motion.div
            initial={{ opacity: 0, x: 30 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.6 }}
          >
            <form onSubmit={handleSubmit} className="bg-white rounded-2xl shadow-xl p-8">
              <div className="space-y-6">
                <div>
                  <label htmlFor="name" className="block text-sm font-semibold text-gray-700 mb-2">
                    Nom complet *
                  </label>
                  <input
                    type="text"
                    id="name"
                    name="name"
                    required
                    value={formData.name}
                    onChange={handleChange}
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all"
                    placeholder="Votre nom"
                  />
                </div>

                <div>
                  <label htmlFor="email" className="block text-sm font-semibold text-gray-700 mb-2">
                    Email *
                  </label>
                  <input
                    type="email"
                    id="email"
                    name="email"
                    required
                    value={formData.email}
                    onChange={handleChange}
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all"
                    placeholder="votre@email.com"
                  />
                </div>

                <div>
                  <label htmlFor="type" className="block text-sm font-semibold text-gray-700 mb-2">
                    Vous êtes *
                  </label>
                  <select
                    id="type"
                    name="type"
                    required
                    value={formData.type}
                    onChange={handleChange}
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all"
                  >
                    <option value="particulier">Particulier / Pèlerin</option>
                    <option value="agence">Agence de voyage</option>
                    <option value="institution">Institution / Autorité</option>
                    <option value="investisseur">Investisseur / Partenaire</option>
                  </select>
                </div>

                <div>
                  <label htmlFor="message" className="block text-sm font-semibold text-gray-700 mb-2">
                    Message *
                  </label>
                  <textarea
                    id="message"
                    name="message"
                    required
                    rows={5}
                    value={formData.message}
                    onChange={handleChange}
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all resize-none"
                    placeholder="Décrivez votre demande..."
                  />
                </div>

                <button
                  type="submit"
                  disabled={isSubmitted}
                  className="w-full bg-primary-600 text-white py-4 rounded-lg font-semibold hover:bg-primary-700 transition-colors flex items-center justify-center space-x-2 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  {isSubmitted ? (
                    <>
                      <span>✓ Message envoyé !</span>
                    </>
                  ) : (
                    <>
                      <Send className="w-5 h-5" />
                      <span>Envoyer le message</span>
                    </>
                  )}
                </button>
              </div>
            </form>
          </motion.div>
        </div>
      </div>
    </section>
  )
}

