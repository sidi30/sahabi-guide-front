import { motion } from 'framer-motion'
import { Download, Smartphone } from 'lucide-react'
import SectionTitle from '../components/SectionTitle'
import CTAButton from '../components/CTAButton'

export default function DownloadApp() {
  return (
    <section id="telechargement" className="py-20 bg-gradient-to-br from-primary-600 to-primary-800 text-white relative overflow-hidden">
      {/* Background Pattern */}
      <div className="absolute inset-0 opacity-10">
        <div className="absolute top-0 left-0 w-96 h-96 bg-white rounded-full filter blur-3xl -translate-x-1/2 -translate-y-1/2"></div>
        <div className="absolute bottom-0 right-0 w-96 h-96 bg-gold-400 rounded-full filter blur-3xl translate-x-1/2 translate-y-1/2"></div>
      </div>

      <div className="container mx-auto px-4 relative z-10">
        <SectionTitle
          title="Téléchargez SahabiGuide"
          subtitle="Commencez votre voyage spirituel avec nous"
        />
        
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6 }}
          className="mt-16 max-w-4xl mx-auto"
        >
          <div className="grid md:grid-cols-2 gap-8 items-center">
            {/* Download Buttons */}
            <div className="space-y-6">
              <motion.div
                whileHover={{ scale: 1.05 }}
                className="bg-white/10 backdrop-blur-sm rounded-2xl p-8 border border-white/20"
              >
                <Smartphone className="w-12 h-12 mb-4" />
                <h3 className="text-2xl font-bold mb-2">Android</h3>
                <p className="text-white/80 mb-6">
                  Disponible sur Google Play Store
                </p>
                <CTAButton 
                  href="#" 
                  variant="secondary" 
                  icon={Download}
                  className="w-full justify-center"
                >
                  Télécharger maintenant
                </CTAButton>
              </motion.div>

              <motion.div
                whileHover={{ scale: 1.05 }}
                className="bg-white/5 backdrop-blur-sm rounded-2xl p-8 border border-white/20"
              >
                <Smartphone className="w-12 h-12 mb-4 opacity-50" />
                <h3 className="text-2xl font-bold mb-2 opacity-50">iOS</h3>
                <p className="text-white/60 mb-6">
                  Bientôt disponible sur l'App Store
                </p>
                <button 
                  disabled
                  className="w-full px-6 py-3 bg-white/20 text-white/50 rounded-lg font-semibold cursor-not-allowed"
                >
                  Prochainement
                </button>
              </motion.div>
            </div>

            {/* QR Code */}
            <motion.div
              initial={{ opacity: 0, scale: 0.9 }}
              whileInView={{ opacity: 1, scale: 1 }}
              viewport={{ once: true }}
              transition={{ duration: 0.6, delay: 0.2 }}
              className="flex flex-col items-center"
            >
              <div className="bg-white rounded-3xl p-8 shadow-2xl">
                <div className="w-64 h-64 bg-gray-100 rounded-2xl flex items-center justify-center">
                  <div className="text-center">
                    <div className="text-6xl mb-4">📱</div>
                    <p className="text-gray-600 font-semibold">Scannez pour télécharger</p>
                  </div>
                </div>
              </div>
              <p className="mt-6 text-center text-white/80">
                Scannez ce QR code avec votre téléphone pour télécharger l'application
              </p>
            </motion.div>
          </div>

          {/* Stats */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.6, delay: 0.4 }}
            className="mt-16 grid grid-cols-2 md:grid-cols-4 gap-6"
          >
            {[
              { number: "10K+", label: "Téléchargements" },
              { number: "4.8", label: "Note moyenne" },
              { number: "50+", label: "Pays" },
              { number: "24/7", label: "Support" }
            ].map((stat, index) => (
              <div key={index} className="text-center">
                <p className="text-4xl font-bold mb-2">{stat.number}</p>
                <p className="text-white/80">{stat.label}</p>
              </div>
            ))}
          </motion.div>
        </motion.div>
      </div>
    </section>
  )
}

