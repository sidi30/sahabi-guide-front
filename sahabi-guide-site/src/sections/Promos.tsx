import { motion } from 'framer-motion'
import { Watch, Smartphone, Building2 } from 'lucide-react'

export default function Promos() {
  const promos = [
    {
      icon: Watch,
      title: "Pack Bracelet Premium",
      description: "Application + Bracelet SahabiBand + Support prioritaire",
      badge: "Recommandé",
      gradient: "from-primary-500 to-primary-700"
    },
    {
      icon: Smartphone,
      title: "Connectivité assurée",
      description: "Partenariat avec opérateurs télécom locaux pour eSIM et recharges",
      badge: "Nouveau",
      gradient: "from-gold-500 to-gold-700"
    },
    {
      icon: Building2,
      title: "Solution Agence",
      description: "Pack complet : Dashboard + Bracelets + Formation + Support",
      badge: "Pro",
      gradient: "from-navy-500 to-navy-700"
    }
  ]

  return (
    <section className="py-12 md:py-16 lg:py-20 bg-gray-50">
      <div className="container mx-auto px-4">
        <div className="text-center mb-8 md:mb-12">
          <h2 className="text-2xl sm:text-3xl md:text-4xl font-bold text-gray-900 mb-3 md:mb-4 font-display px-2">
            Offres spéciales
          </h2>
          <p className="text-base sm:text-lg text-gray-600 px-4">
            Découvrez nos solutions complètes adaptées à vos besoins
          </p>
        </div>

        <div className="grid sm:grid-cols-2 md:grid-cols-3 gap-4 md:gap-6 lg:gap-8">
          {promos.map((promo, index) => (
            <motion.div
              key={promo.title}
              initial={{ opacity: 0, y: 30 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.5, delay: index * 0.1 }}
              whileHover={{ y: -8 }}
              className="relative"
            >
              <div className={`bg-gradient-to-br ${promo.gradient} rounded-2xl p-8 text-white shadow-xl h-full flex flex-col`}>
                {/* Badge */}
                <div className="absolute top-4 right-4">
                  <span className="bg-white/20 backdrop-blur-sm px-3 py-1 rounded-full text-xs font-semibold">
                    {promo.badge}
                  </span>
                </div>

                {/* Icon */}
                <div className="mb-6">
                  <promo.icon className="w-12 h-12" />
                </div>

                {/* Content */}
                <h3 className="text-2xl font-bold mb-4">{promo.title}</h3>
                <p className="text-white/90 flex-1">{promo.description}</p>

                {/* CTA */}
                <button className="mt-6 w-full bg-white text-gray-900 py-3 rounded-lg font-semibold hover:bg-gray-100 transition-colors">
                  En savoir plus
                </button>
              </div>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  )
}

