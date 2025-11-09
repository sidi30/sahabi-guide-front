import { motion } from 'framer-motion'
import { MapPin, Heart, QrCode, AlertCircle } from 'lucide-react'
import SectionTitle from '../components/SectionTitle'
import CTAButton from '../components/CTAButton'

export default function Bracelet() {
  const features = [
    {
      icon: MapPin,
      title: "Géolocalisation en temps réel",
      description: "Votre famille peut vous suivre sur une carte interactive et être rassurée à tout moment."
    },
    {
      icon: Heart,
      title: "Suivi santé",
      description: "Surveillance des paramètres vitaux de base adaptés aux conditions du pèlerinage."
    },
    {
      icon: QrCode,
      title: "Identification rapide",
      description: "QR code intégré pour une identification instantanée en cas de besoin médical ou administratif."
    },
    {
      icon: AlertCircle,
      title: "Bouton SOS",
      description: "Déclenchez une alerte d'urgence en un seul geste. Les secours et votre groupe sont immédiatement notifiés."
    }
  ]

  return (
    <section id="bracelet" className="py-12 md:py-16 lg:py-20 bg-white">
      <div className="container mx-auto px-4">
        <SectionTitle
          title="Bracelet connecté SahabiBand"
          subtitle="Votre sécurité et celle de vos proches, au poignet"
        />
        
        <div className="mt-8 md:mt-12 lg:mt-16 grid lg:grid-cols-2 gap-8 md:gap-12 items-center">
          {/* Visual */}
          <motion.div
            initial={{ opacity: 0, scale: 0.9 }}
            whileInView={{ opacity: 1, scale: 1 }}
            viewport={{ once: true }}
            transition={{ duration: 0.6 }}
            className="relative"
          >
            <div className="relative bg-gradient-to-br from-primary-100 to-gold-100 rounded-3xl p-12 shadow-2xl">
              <motion.div
                animate={{ rotate: [0, 5, 0, -5, 0] }}
                transition={{ duration: 5, repeat: Infinity, ease: "easeInOut" }}
                className="relative"
              >
                {/* Bracelet Illustration */}
                <div className="w-64 h-64 mx-auto bg-white rounded-full shadow-xl flex items-center justify-center border-8 border-primary-600">
                  <div className="text-center">
                    <div className="text-6xl mb-2">⌚</div>
                    <p className="text-sm font-bold text-primary-600">SahabiBand</p>
                  </div>
                </div>
              </motion.div>
              
              {/* Floating indicators */}
              <motion.div
                animate={{ y: [0, -10, 0] }}
                transition={{ duration: 2, repeat: Infinity, ease: "easeInOut" }}
                className="absolute top-8 right-8 bg-white rounded-lg p-3 shadow-lg"
              >
                <Heart className="w-6 h-6 text-red-500" />
              </motion.div>
              
              <motion.div
                animate={{ y: [0, 10, 0] }}
                transition={{ duration: 2.5, repeat: Infinity, ease: "easeInOut" }}
                className="absolute bottom-8 left-8 bg-white rounded-lg p-3 shadow-lg"
              >
                <MapPin className="w-6 h-6 text-primary-600" />
              </motion.div>
            </div>
          </motion.div>

          {/* Features List */}
          <div className="space-y-6">
            {features.map((feature, index) => (
              <motion.div
                key={feature.title}
                initial={{ opacity: 0, x: 30 }}
                whileInView={{ opacity: 1, x: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.5, delay: index * 0.1 }}
                className="flex items-start space-x-4 bg-gray-50 rounded-xl p-6 hover:shadow-lg transition-shadow"
              >
                <div className="flex-shrink-0 w-12 h-12 bg-primary-600 rounded-lg flex items-center justify-center">
                  <feature.icon className="w-6 h-6 text-white" />
                </div>
                <div>
                  <h3 className="text-lg font-bold text-gray-900 mb-2">{feature.title}</h3>
                  <p className="text-gray-600">{feature.description}</p>
                </div>
              </motion.div>
            ))}
            
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.5, delay: 0.5 }}
              className="pt-4"
            >
              <CTAButton href="#contact" variant="secondary">
                En savoir plus sur le SahabiBand
              </CTAButton>
            </motion.div>
          </div>
        </div>
      </div>
    </section>
  )
}

