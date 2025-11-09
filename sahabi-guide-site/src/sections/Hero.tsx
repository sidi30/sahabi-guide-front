import { motion } from 'framer-motion'
import { Download, ChevronDown } from 'lucide-react'
import CTAButton from '../components/CTAButton'
import mascotteVideo from '../assets/mascott-anime.mp4'
import logoVideo from '../assets/logo-anime.mp4'

export default function Hero() {
  return (
    <section id="accueil" className="relative min-h-screen flex items-center justify-center bg-gradient-to-br from-primary-50 via-white to-gold-50 pt-20">
      <div className="container mx-auto px-4 py-12 md:py-20">
        <div className="grid lg:grid-cols-2 gap-8 md:gap-12 items-center">
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
              className="text-3xl sm:text-4xl md:text-5xl lg:text-6xl font-bold text-gray-900 mb-4 md:mb-6 font-display leading-tight"
            >
              SahabiGuide
            </motion.h1>
            
            <motion.p
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.8, delay: 0.3 }}
              className="text-lg sm:text-xl md:text-2xl text-primary-600 font-semibold mb-4 md:mb-6"
            >
              Votre compagnon numérique pour un Hadj serein et connecté
            </motion.p>
            
            <motion.p
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.8, delay: 0.4 }}
              className="text-base md:text-lg text-gray-600 mb-6 md:mb-8 leading-relaxed"
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
              className="flex flex-col gap-3 sm:gap-4 justify-center lg:justify-start"
            >
              <CTAButton href="#telechargement" icon={Download} size="md" className="w-full sm:w-auto">
                Télécharger sur Android
              </CTAButton>
              <CTAButton href="#fonctionnalites" variant="outline" size="md" className="w-full sm:w-auto">
                Découvrir la solution
              </CTAButton>
            </motion.div>
          </motion.div>

          {/* Visual Illustration with Mascot */}
          <motion.div
            initial={{ opacity: 0, x: 50 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.8, delay: 0.3 }}
            className="relative mt-8 lg:mt-0 overflow-hidden"
          >
            <div className="relative w-full max-w-sm sm:max-w-md mx-auto px-4 sm:px-0">
              {/* Mascotte animée */}
              <motion.div
                animate={{ y: [0, -20, 0] }}
                transition={{ duration: 4, repeat: Infinity, ease: "easeInOut" }}
                className="relative z-10 rounded-2xl md:rounded-3xl shadow-xl md:shadow-2xl overflow-hidden bg-gradient-to-br from-primary-50 to-gold-50"
              >
                <video 
                  autoPlay 
                  loop 
                  muted 
                  playsInline
                  className="w-full h-auto rounded-xl md:rounded-2xl"
                >
                  <source src={mascotteVideo} type="video/mp4" />
                </video>
              </motion.div>

              {/* Logo animé en background */}
              <motion.div
                animate={{ rotate: [0, 360] }}
                transition={{ duration: 20, repeat: Infinity, ease: "linear" }}
                className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 w-64 h-64 sm:w-80 sm:h-80 md:w-96 md:h-96 -z-10 opacity-10"
              >
                <video 
                  autoPlay 
                  loop 
                  muted 
                  playsInline
                  className="w-full h-full object-contain"
                >
                  <source src={logoVideo} type="video/mp4" />
                </video>
              </motion.div>

              {/* Floating Icons - Cachés sur très petits écrans */}
              <motion.div
                animate={{ y: [0, -15, 0], rotate: [0, 5, 0] }}
                transition={{ duration: 4, repeat: Infinity, ease: "easeInOut" }}
                className="hidden sm:block absolute -top-4 -right-4 md:-top-8 md:-right-8 bg-gold-100 rounded-full p-3 md:p-4 shadow-lg"
              >
                <span className="text-2xl md:text-3xl">📍</span>
              </motion.div>

              <motion.div
                animate={{ y: [0, 15, 0], rotate: [0, -5, 0] }}
                transition={{ duration: 3.5, repeat: Infinity, ease: "easeInOut" }}
                className="hidden sm:block absolute -bottom-2 -left-4 md:-bottom-4 md:-left-8 bg-primary-100 rounded-full p-3 md:p-4 shadow-lg"
              >
                <span className="text-2xl md:text-3xl">💬</span>
              </motion.div>

              <motion.div
                animate={{ y: [0, -10, 0], scale: [1, 1.1, 1] }}
                transition={{ duration: 3, repeat: Infinity, ease: "easeInOut" }}
                className="hidden sm:block absolute top-1/4 -left-6 md:-left-12 bg-red-100 rounded-full p-2 md:p-3 shadow-lg"
              >
                <span className="text-xl md:text-2xl">❤️</span>
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

