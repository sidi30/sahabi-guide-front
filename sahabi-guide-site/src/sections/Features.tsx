import SectionTitle from '../components/SectionTitle'
import Card from '../components/Card'
import { features } from '../data/features'

export default function Features() {
  return (
    <section id="fonctionnalites" className="py-20 bg-white">
      <div className="container mx-auto px-4">
        <SectionTitle
          title="Fonctionnalités principales"
          subtitle="Tout ce dont vous avez besoin pour un pèlerinage serein"
        />
        
        <div className="mt-16 grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
          {features.map((feature, index) => (
            <Card
              key={feature.title}
              title={feature.title}
              description={feature.description}
              icon={feature.icon}
              iconColor="text-primary-600"
              delay={index * 0.05}
            />
          ))}
        </div>
      </div>
    </section>
  )
}

