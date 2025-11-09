import { motion } from 'framer-motion'
import { Users, Bell, MessageSquare, BarChart3 } from 'lucide-react'
import SectionTitle from '../components/SectionTitle'

export default function Agencies() {
  const features = [
    {
      icon: Users,
      title: "Suivi des groupes en temps réel",
      description: "Visualisez la position de tous vos pèlerins sur une carte interactive."
    },
    {
      icon: Bell,
      title: "Gestion des alertes",
      description: "Recevez et gérez les alertes de santé, sécurité ou logistique instantanément."
    },
    {
      icon: MessageSquare,
      title: "Communication simplifiée",
      description: "Envoyez des messages groupés ou individuels à vos pèlerins."
    },
    {
      icon: BarChart3,
      title: "Rapports et statistiques",
      description: "Accédez à des tableaux de bord détaillés et exportez vos données."
    }
  ]

  return (
    <section id="agences" className="py-12 md:py-16 lg:py-20 bg-gray-50">
      <div className="container mx-auto px-4">
        <SectionTitle
          title="Dashboard pour Agences"
          subtitle="Gérez vos groupes de pèlerins avec efficacité et professionnalisme"
        />
        
        <div className="mt-8 md:mt-12 lg:mt-16 grid lg:grid-cols-2 gap-8 md:gap-12 items-center">
          {/* Dashboard Mockups */}
          <motion.div
            initial={{ opacity: 0, x: -30 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.6 }}
            className="space-y-4"
          >
            {/* Main Dashboard Card */}
            <div className="bg-white rounded-xl shadow-xl p-6 border border-gray-200">
              <div className="flex items-center justify-between mb-4">
                <h3 className="font-bold text-gray-900">Vue d'ensemble</h3>
                <span className="text-sm text-gray-500">Aujourd'hui</span>
              </div>
              <div className="grid grid-cols-3 gap-4 mb-6">
                <div className="bg-primary-50 rounded-lg p-4">
                  <p className="text-sm text-gray-600 mb-1">Pèlerins actifs</p>
                  <p className="text-2xl font-bold text-primary-600">247</p>
                </div>
                <div className="bg-gold-50 rounded-lg p-4">
                  <p className="text-sm text-gray-600 mb-1">Alertes</p>
                  <p className="text-2xl font-bold text-gold-600">3</p>
                </div>
                <div className="bg-green-50 rounded-lg p-4">
                  <p className="text-sm text-gray-600 mb-1">Rituels terminés</p>
                  <p className="text-2xl font-bold text-green-600">89%</p>
                </div>
              </div>
              <div className="bg-gray-50 rounded-lg h-32 flex items-center justify-center">
                <div className="text-center">
                  <MapPin className="w-8 h-8 text-primary-600 mx-auto mb-2" />
                  <p className="text-sm text-gray-600">Carte interactive des pèlerins</p>
                </div>
              </div>
            </div>

            {/* Alerts Card */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.5, delay: 0.2 }}
              className="bg-white rounded-xl shadow-lg p-6 border border-gray-200"
            >
              <h3 className="font-bold text-gray-900 mb-4">Alertes récentes</h3>
              <div className="space-y-3">
                <div className="flex items-center space-x-3 p-3 bg-red-50 rounded-lg">
                  <AlertCircle className="w-5 h-5 text-red-500" />
                  <p className="text-sm text-gray-700">Alerte santé - Pèlerin #142</p>
                </div>
                <div className="flex items-center space-x-3 p-3 bg-yellow-50 rounded-lg">
                  <Bell className="w-5 h-5 text-yellow-600" />
                  <p className="text-sm text-gray-700">Rappel groupe - Départ bus 15:30</p>
                </div>
              </div>
            </motion.div>
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
                className="flex items-start space-x-4"
              >
                <div className="flex-shrink-0 w-12 h-12 bg-primary-100 rounded-lg flex items-center justify-center">
                  <feature.icon className="w-6 h-6 text-primary-600" />
                </div>
                <div>
                  <h3 className="text-xl font-bold text-gray-900 mb-2">{feature.title}</h3>
                  <p className="text-gray-600">{feature.description}</p>
                </div>
              </motion.div>
            ))}
            
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.5, delay: 0.5 }}
              className="pt-6 pl-16"
            >
              <p className="text-gray-700 font-medium mb-4">
                Intéressé par notre solution pour agences ?
              </p>
              <a
                href="#contact"
                className="inline-flex items-center text-primary-600 font-semibold hover:text-primary-700 transition-colors"
              >
                Demander une démonstration →
              </a>
            </motion.div>
          </div>
        </div>
      </div>
    </section>
  )
}

function AlertCircle(props: React.SVGProps<SVGSVGElement>) {
  return (
    <svg {...props} xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <circle cx="12" cy="12" r="10" />
      <line x1="12" x2="12" y1="8" y2="12" />
      <line x1="12" x2="12.01" y1="16" y2="16" />
    </svg>
  )
}

function MapPin(props: React.SVGProps<SVGSVGElement>) {
  return (
    <svg {...props} xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z" />
      <circle cx="12" cy="10" r="3" />
    </svg>
  )
}

