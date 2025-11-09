import { motion } from 'framer-motion'
import { LucideIcon } from 'lucide-react'

interface CTAButtonProps {
  children: React.ReactNode
  href?: string
  onClick?: () => void
  variant?: 'primary' | 'secondary' | 'outline'
  icon?: LucideIcon
  className?: string
  size?: 'sm' | 'md' | 'lg'
}

export default function CTAButton({
  children,
  href,
  onClick,
  variant = 'primary',
  icon: Icon,
  className = '',
  size = 'md'
}: CTAButtonProps) {
  const baseStyles = 'inline-flex items-center justify-center gap-2 rounded-lg font-semibold transition-all duration-200'
  
  const variants = {
    primary: 'bg-primary-600 text-white hover:bg-primary-700 shadow-lg hover:shadow-xl',
    secondary: 'bg-gold-500 text-white hover:bg-gold-600 shadow-lg hover:shadow-xl',
    outline: 'border-2 border-primary-600 text-primary-600 hover:bg-primary-50'
  }

  const sizes = {
    sm: 'px-3 py-2 text-xs sm:text-sm',
    md: 'px-4 py-2.5 sm:px-6 sm:py-3 text-sm sm:text-base',
    lg: 'px-6 py-3 sm:px-8 sm:py-4 text-base sm:text-lg'
  }

  const classes = `${baseStyles} ${variants[variant]} ${sizes[size]} ${className}`

  const content = (
    <>
      {Icon && <Icon className="w-4 h-4 sm:w-5 sm:h-5" />}
      {children}
    </>
  )

  if (href) {
    return (
      <motion.a
        href={href}
        className={classes}
        whileHover={{ scale: 1.05 }}
        whileTap={{ scale: 0.95 }}
      >
        {content}
      </motion.a>
    )
  }

  return (
    <motion.button
      onClick={onClick}
      className={classes}
      whileHover={{ scale: 1.05 }}
      whileTap={{ scale: 0.95 }}
    >
      {content}
    </motion.button>
  )
}

