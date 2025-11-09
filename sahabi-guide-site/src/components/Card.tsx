import { motion } from 'framer-motion'
import { LucideIcon } from 'lucide-react'

interface CardProps {
  title: string
  description: string
  icon?: LucideIcon
  iconColor?: string
  delay?: number
  className?: string
}

export default function Card({ title, description, icon: Icon, iconColor = 'text-primary-600', delay = 0, className = '' }: CardProps) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 30 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true }}
      transition={{ duration: 0.5, delay }}
      whileHover={{ y: -8, transition: { duration: 0.2 } }}
      className={`bg-white rounded-xl p-6 shadow-lg hover:shadow-2xl transition-shadow duration-300 border border-gray-100 ${className}`}
    >
      {Icon && (
        <div className={`${iconColor} mb-4`}>
          <Icon className="w-12 h-12" />
        </div>
      )}
      <h3 className="text-xl font-bold text-gray-900 mb-3">{title}</h3>
      <p className="text-gray-600 leading-relaxed">{description}</p>
    </motion.div>
  )
}

