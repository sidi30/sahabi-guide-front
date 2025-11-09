import { motion } from 'framer-motion'
import { Download, ChevronDown } from 'lucide-react'
import CTAButton from '../components/CTAButton'

export default function Hero() {
  return (
    <section id="accueil" className="relative min-h-screen flex items-center justify-center bg-gradient-to-br from-primary-50 via-white to-gold-50 pt-20">
      <div className="container mx-auto px-4 py-20">
        <div className="grid lg:grid-cols-2 gap-12 items-center">
          {/* Text Content */}
          <motion.div
            initial={{ opacity: 0, x: -50 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.8 }}
            className="text-center lg:text-left"
          >
            <motion.h1
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.8, delay: 0.2 }}
              className="text-4xl md:text-5xl lg:text-6xl font-bold text-gray-900 mb-6 font-display"
            >
              SahabiGuide
            </motion.h1>
            
            <motion.p
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.8, delay: 0.3 }}
              className="text-xl md:text-2xl text-primary-600 font-semibold mb-6"
            >
              Votre compagnon numérique pour un Hadj serein et connecté
            </motion.p>
            
            <motion.p
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.8, delay: 0.4 }}
              className="text-lg text-gray-600 mb-8 leading-relaxed"
            >
              Une solution complète combinant une <strong>application mobile</strong>, 
              un <strong>assistant IA intelligent</strong>, un <strong>bracelet connecté</strong> 
              et un <strong>dashboard pour agences</strong>. 
              Tout pour accompagner les pèlerins avant, pendant et après leur voyage sacré.
            </motion.p>
            
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.8, delay: 0.5 }}
              className="flex flex-col sm:flex-row gap-4 justify-center lg:justify-start"
            >
              <CTAButton href="#telechargement" icon={Download} size="lg">
                Télécharger sur Android
              </CTAButton>
              <CTAButton href="#fonctionnalites" variant="outline" size="lg">
                Découvrir la solution
              </CTAButton>
            </motion.div>
          </motion.div>

          {/* Visual Illustration */}
          <motion.div
            initial={{ opacity: 0, x: 50 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.8, delay: 0.3 }}
            className="relative"
          >
            <div className="relative w-full max-w-md mx-auto">
              {/* Phone Mockup */}
              <motion.div
                animate={{ y: [0, -10, 0] }}
                transition={{ duration: 3, repeat: Infinity, ease: "easeInOut" }}
                className="relative z-10 bg-white rounded-3xl shadow-2xl p-4 border-8 border-gray-800"
              >
                <div className="bg-gradient-to-br from-primary-500 to-primary-700 rounded-2xl h-96 flex items-center justify-center">
                  <div className="text-white text-center p-6">
                    <div className="text-6xl mb-4">🕋</div>
                    <p className="text-xl font-semibold">Application SahabiGuide</p>
                  </div>
                </div>
              </motion.div>

              {/* Floating Icons */}
              <motion.div
                animate={{ y: [0, -15, 0], rotate: [0, 5, 0] }}
                transition={{ duration: 4, repeat: Infinity, ease: "easeInOut" }}
                className="absolute -top-8 -right-8 bg-gold-100 rounded-full p-4 shadow-lg"
              >
                <span className="text-3xl">📍</span>
              </motion.div>

              <motion.div
                animate={{ y: [0, 15, 0], rotate: [0, -5, 0] }}
                transition={{ duration: 3.5, repeat: Infinity, ease: "easeInOut" }}
                className="absolute -bottom-4 -left-8 bg-primary-100 rounded-full p-4 shadow-lg"
              >
                <span className="text-3xl">💬</span>
              </motion.div>

              <motion.div
                animate={{ y: [0, -10, 0], scale: [1, 1.1, 1] }}
                transition={{ duration: 3, repeat: Infinity, ease: "easeInOut" }}
                className="absolute top-1/4 -left-12 bg-red-100 rounded-full p-3 shadow-lg"
              >
                <span className="text-2xl">❤️</span>
              </motion.div>
            </div>
          </motion.div>
        </div>
      </div>

      {/* Scroll Indicator */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 1, duration: 1 }}
        className="absolute bottom-8 left-1/2 transform -translate-x-1/2"
      >
        <motion.div
          animate={{ y: [0, 10, 0] }}
          transition={{ duration: 1.5, repeat: Infinity }}
        >
          <ChevronDown className="w-8 h-8 text-primary-600" />
        </motion.div>
      </motion.div>
    </section>
  )
}

