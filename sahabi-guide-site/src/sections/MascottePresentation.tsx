import { motion } from 'framer-motion'
import mascotteGuideVideo from '../assets/mascotte_anim_e_repr_sentant_un_guide_de_p_lerinage.mp4'
import mascotteImage from '../assets/mascott.jpeg'

export default function MascottePresentation() {
  return (
    <section className="py-20 bg-gradient-to-br from-white via-primary-50 to-gold-50 relative overflow-hidden">
      {/* Decorative background */}
      <div className="absolute inset-0 opacity-5">
        <div className="absolute top-10 left-10 text-9xl">🕋</div>
        <div className="absolute bottom-10 right-10 text-9xl">🕌</div>
      </div>

      <div className="container mx-auto px-4 relative z-10">
        <div className="grid lg:grid-cols-2 gap-12 items-center">
          {/* Video Section */}
          <motion.div
            initial={{ opacity: 0, x: -50 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.8 }}
            className="relative"
          >
            <div className="relative rounded-3xl overflow-hidden shadow-2xl">
              <video 
                autoPlay 
                loop 
                muted 
                playsInline
                poster={mascotteImage}
                className="w-full h-auto"
              >
                <source src={mascotteGuideVideo} type="video/mp4" />
              </video>
              
              {/* Overlay gradient */}
              <div className="absolute inset-0 bg-gradient-to-t from-primary-900/20 to-transparent pointer-events-none"></div>
            </div>

            {/* Floating badge */}
            <motion.div
              initial={{ scale: 0 }}
              whileInView={{ scale: 1 }}
              viewport={{ once: true }}
              transition={{ delay: 0.5, type: "spring" }}
              className="absolute -bottom-6 -right-6 bg-gold-500 text-white rounded-full p-6 shadow-xl"
            >
              <div className="text-center">
                <p className="text-3xl font-bold">24/7</p>
                <p className="text-xs font-semibold">Assistance</p>
              </div>
            </motion.div>
          </motion.div>

          {/* Content Section */}
          <motion.div
            initial={{ opacity: 0, x: 50 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.8, delay: 0.2 }}
          >
            <div className="mb-6">
              <span className="inline-block bg-primary-100 text-primary-700 px-4 py-2 rounded-full text-sm font-semibold mb-4">
                Votre guide personnel
              </span>
              <h2 className="text-4xl md:text-5xl font-bold text-gray-900 mb-6 font-display">
                Un compagnon à chaque étape de votre voyage
              </h2>
              <p className="text-xl text-gray-600 leading-relaxed mb-8">
                Notre mascotte vous accompagne dans votre parcours spirituel avec bienveillance et expertise. 
                Comme un ami fidèle, elle est toujours là pour vous guider, vous rassurer et vous aider à vivre 
                pleinement chaque moment de votre pèlerinage.
              </p>
            </div>

            <div className="space-y-4">
              {[
                {
                  icon: "🎯",
                  title: "Guidance personnalisée",
                  description: "Des conseils adaptés à votre situation et vos besoins spécifiques"
                },
                {
                  icon: "🗣️",
                  title: "Communication multilingue",
                  description: "Parlez dans votre langue, nous vous comprenons"
                },
                {
                  icon: "🤝",
                  title: "Support constant",
                  description: "Une présence rassurante disponible jour et nuit"
                }
              ].map((item, index) => (
                <motion.div
                  key={index}
                  initial={{ opacity: 0, y: 20 }}
                  whileInView={{ opacity: 1, y: 0 }}
                  viewport={{ once: true }}
                  transition={{ delay: 0.3 + index * 0.1 }}
                  className="flex items-start space-x-4 p-4 bg-white rounded-xl shadow-sm hover:shadow-md transition-shadow"
                >
                  <span className="text-3xl flex-shrink-0">{item.icon}</span>
                  <div>
                    <h3 className="font-bold text-gray-900 mb-1">{item.title}</h3>
                    <p className="text-gray-600 text-sm">{item.description}</p>
                  </div>
                </motion.div>
              ))}
            </div>
          </motion.div>
        </div>
      </div>
    </section>
  )
}


