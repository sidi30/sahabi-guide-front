import { motion } from 'framer-motion'
import { Bot, MessageCircle, Bell, Users } from 'lucide-react'
import SectionTitle from '../components/SectionTitle'

export default function AssistantAI() {
  const messages = [
    { from: 'user', text: "Quelle est la première étape du Hadj ?" },
    { from: 'bot', text: "La première étape est l'Ihram. C'est l'état de sacralisation que vous devez atteindre avant d'entrer à La Mecque..." },
    { from: 'user', text: "Peux-tu me rappeler les horaires de prière ?" },
    { from: 'bot', text: "Bien sûr ! Je vais activer les rappels de prière pour votre localisation. 🕌" }
  ]

  return (
    <section id="assistant" className="py-20 bg-gradient-to-br from-primary-50 to-white">
      <div className="container mx-auto px-4">
        <SectionTitle
          title="Assistant IA Sahabi"
          subtitle="Votre compagnon intelligent disponible 24h/24"
        />
        
        <div className="mt-16 grid lg:grid-cols-2 gap-12 items-center">
          {/* Features List */}
          <div className="space-y-6">
            <motion.div
              initial={{ opacity: 0, x: -30 }}
              whileInView={{ opacity: 1, x: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.5 }}
              className="flex items-start space-x-4"
            >
              <div className="flex-shrink-0 w-12 h-12 bg-primary-100 rounded-lg flex items-center justify-center">
                <MessageCircle className="w-6 h-6 text-primary-600" />
              </div>
              <div>
                <h3 className="text-xl font-bold text-gray-900 mb-2">Réponses en langue locale</h3>
                <p className="text-gray-600">
                  Posez vos questions en français, haoussa, zarma ou arabe. L'assistant comprend et répond dans votre langue.
                </p>
              </div>
            </motion.div>

            <motion.div
              initial={{ opacity: 0, x: -30 }}
              whileInView={{ opacity: 1, x: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.5, delay: 0.1 }}
              className="flex items-start space-x-4"
            >
              <div className="flex-shrink-0 w-12 h-12 bg-gold-100 rounded-lg flex items-center justify-center">
                <Bell className="w-6 h-6 text-gold-600" />
              </div>
              <div>
                <h3 className="text-xl font-bold text-gray-900 mb-2">Rappels intelligents</h3>
                <p className="text-gray-600">
                  Recevez des rappels pour les prières, les rendez-vous et les étapes importantes de votre pèlerinage.
                </p>
              </div>
            </motion.div>

            <motion.div
              initial={{ opacity: 0, x: -30 }}
              whileInView={{ opacity: 1, x: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.5, delay: 0.2 }}
              className="flex items-start space-x-4"
            >
              <div className="flex-shrink-0 w-12 h-12 bg-primary-100 rounded-lg flex items-center justify-center">
                <Bot className="w-6 h-6 text-primary-600" />
              </div>
              <div>
                <h3 className="text-xl font-bold text-gray-900 mb-2">Explications pédagogiques</h3>
                <p className="text-gray-600">
                  Comprenez chaque rituel avec des explications simples, adaptées à votre niveau de connaissance.
                </p>
              </div>
            </motion.div>

            <motion.div
              initial={{ opacity: 0, x: -30 }}
              whileInView={{ opacity: 1, x: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.5, delay: 0.3 }}
              className="flex items-start space-x-4"
            >
              <div className="flex-shrink-0 w-12 h-12 bg-gold-100 rounded-lg flex items-center justify-center">
                <Users className="w-6 h-6 text-gold-600" />
              </div>
              <div>
                <h3 className="text-xl font-bold text-gray-900 mb-2">Réseau d'imams partenaires</h3>
                <p className="text-gray-600">
                  Pour les questions complexes, l'assistant vous met en contact avec un imam réel pour un conseil personnalisé.
                </p>
              </div>
            </motion.div>
          </div>

          {/* Chat Mockup */}
          <motion.div
            initial={{ opacity: 0, x: 30 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.5 }}
            className="relative"
          >
            <div className="bg-white rounded-2xl shadow-2xl p-6 border border-gray-200">
              <div className="flex items-center space-x-3 mb-6 pb-4 border-b border-gray-200">
                <div className="w-10 h-10 bg-primary-600 rounded-full flex items-center justify-center">
                  <Bot className="w-6 h-6 text-white" />
                </div>
                <div>
                  <h4 className="font-bold text-gray-900">Assistant Sahabi</h4>
                  <p className="text-sm text-green-600">● En ligne</p>
                </div>
              </div>

              <div className="space-y-4 max-h-96 overflow-y-auto">
                {messages.map((message, index) => (
                  <motion.div
                    key={index}
                    initial={{ opacity: 0, y: 20 }}
                    whileInView={{ opacity: 1, y: 0 }}
                    viewport={{ once: true }}
                    transition={{ duration: 0.3, delay: index * 0.2 }}
                    className={`flex ${message.from === 'user' ? 'justify-end' : 'justify-start'}`}
                  >
                    <div
                      className={`max-w-xs px-4 py-3 rounded-2xl ${
                        message.from === 'user'
                          ? 'bg-primary-600 text-white'
                          : 'bg-gray-100 text-gray-900'
                      }`}
                    >
                      <p className="text-sm">{message.text}</p>
                    </div>
                  </motion.div>
                ))}
              </div>

              <div className="mt-6 pt-4 border-t border-gray-200">
                <div className="flex items-center space-x-2">
                  <input
                    type="text"
                    placeholder="Posez votre question..."
                    className="flex-1 px-4 py-2 border border-gray-300 rounded-full focus:outline-none focus:ring-2 focus:ring-primary-500"
                    disabled
                  />
                  <button className="w-10 h-10 bg-primary-600 text-white rounded-full flex items-center justify-center hover:bg-primary-700 transition-colors">
                    <MessageCircle className="w-5 h-5" />
                  </button>
                </div>
              </div>
            </div>
          </motion.div>
        </div>
      </div>
    </section>
  )
}

