import { motion } from 'framer-motion'

export default function Animations() {
  const icons = ['🕋', '🕌', '🌙', '⭐', '🤲', '📿']

  return (
    <section className="py-16 bg-gradient-to-b from-white to-primary-50 overflow-hidden relative">
      <div className="container mx-auto px-4">
        <div className="flex justify-center items-center space-x-4 sm:space-x-8 md:space-x-16 flex-wrap gap-y-4">
          {icons.map((icon, index) => (
            <motion.div
              key={index}
              initial={{ opacity: 0, y: 20 }}
              animate={{
                opacity: 1,
                y: [0, -15, 0],
                rotate: [0, 5, -5, 0]
              }}
              transition={{
                opacity: { duration: 0.5, delay: index * 0.1 },
                y: { duration: 3 + index * 0.5, repeat: Infinity, ease: "easeInOut" },
                rotate: { duration: 3 + index * 0.5, repeat: Infinity, ease: "easeInOut" }
              }}
              className="text-4xl sm:text-5xl md:text-6xl opacity-60 hover:opacity-100 transition-opacity"
            >
              {icon}
            </motion.div>
          ))}
        </div>
      </div>

      {/* Decorative waves */}
      <div className="absolute bottom-0 left-0 right-0">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1440 120" className="w-full">
          <path
            fill="#f0fdf4"
            fillOpacity="0.5"
            d="M0,64L48,69.3C96,75,192,85,288,80C384,75,480,53,576,48C672,43,768,53,864,58.7C960,64,1056,64,1152,58.7C1248,53,1344,43,1392,37.3L1440,32L1440,120L1392,120C1344,120,1248,120,1152,120C1056,120,960,120,864,120C768,120,672,120,576,120C480,120,384,120,288,120C192,120,96,120,48,120L0,120Z"
          ></path>
        </svg>
      </div>
    </section>
  )
}

