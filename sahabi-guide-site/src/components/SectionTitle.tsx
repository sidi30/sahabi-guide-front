import { motion } from 'framer-motion'

interface SectionTitleProps {
  title: string
  subtitle?: string
  centered?: boolean
  className?: string
}

export default function SectionTitle({ title, subtitle, centered = true, className = '' }: SectionTitleProps) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true }}
      transition={{ duration: 0.6 }}
      className={`${centered ? 'text-center' : ''} ${className} mb-8 md:mb-12`}
    >
      <h2 className="text-2xl sm:text-3xl md:text-4xl lg:text-5xl font-bold font-display text-gray-900 mb-3 md:mb-4 px-2">
        {title}
      </h2>
      {subtitle && (
        <p className="text-base sm:text-lg md:text-xl text-gray-600 max-w-3xl mx-auto px-4">
          {subtitle}
        </p>
      )}
    </motion.div>
  )
}

