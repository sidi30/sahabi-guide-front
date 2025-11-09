import SectionTitle from '../components/SectionTitle'
import Card from '../components/Card'
import { personas } from '../data/personas'

export default function ForWho() {
  return (
    <section id="pour-qui" className="py-12 md:py-16 lg:py-20 bg-gray-50">
      <div className="container mx-auto px-4">
        <SectionTitle
          title="Pour qui ?"
          subtitle="SahabiGuide s'adresse à tous les acteurs du pèlerinage"
        />
        
        <div className="mt-8 md:mt-12 lg:mt-16 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 md:gap-6 lg:gap-8">
          {personas.map((persona, index) => (
            <Card
              key={persona.title}
              title={persona.title}
              description={persona.description}
              icon={persona.icon}
              iconColor="text-gold-600"
              delay={index * 0.1}
            />
          ))}
        </div>
      </div>
    </section>
  )
}

