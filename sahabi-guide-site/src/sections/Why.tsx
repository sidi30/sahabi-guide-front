import { Heart, Shield, Users, TrendingUp } from 'lucide-react'
import SectionTitle from '../components/SectionTitle'
import Card from '../components/Card'

export default function Why() {
  const benefits = [
    {
      icon: Heart,
      title: "Accompagnement spirituel",
      description: "Un guide complet pour vivre pleinement votre pèlerinage avec sérénité et confiance."
    },
    {
      icon: Shield,
      title: "Sécurité et santé",
      description: "Géolocalisation, suivi santé et alertes pour garantir votre sécurité à chaque instant."
    },
    {
      icon: Users,
      title: "Famille rassurée",
      description: "Vos proches peuvent vous suivre en temps réel et rester connectés avec vous."
    },
    {
      icon: TrendingUp,
      title: "Organisation moderne pour agences",
      description: "Outils professionnels pour gérer efficacement les groupes et optimiser l'expérience."
    }
  ]

  return (
    <section className="py-12 md:py-16 lg:py-20 bg-white">
      <div className="container mx-auto px-4">
        <SectionTitle
          title="Pourquoi choisir SahabiGuide ?"
          subtitle="Une solution complète pensée pour tous les acteurs du pèlerinage"
        />
        
        <div className="mt-8 md:mt-12 lg:mt-16 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 md:gap-6 lg:gap-8">
          {benefits.map((benefit, index) => (
            <Card
              key={benefit.title}
              title={benefit.title}
              description={benefit.description}
              icon={benefit.icon}
              iconColor="text-primary-600"
              delay={index * 0.1}
            />
          ))}
        </div>
      </div>
    </section>
  )
}

