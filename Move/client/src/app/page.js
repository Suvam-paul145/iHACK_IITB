"use client";
import FeatureSection from "@/components/FeatureSection";
import HeroSection from "@/components/HeroSection";
import Navbar from "@/components/Navbar";
import LetsPlaySection from "@/components/LetsPlaySection";
import FeatureGameSection from "@/components/FeatureGameSection";

export default function Home() {
 

  return (
    <div className="bg-[#070005]">
      <Navbar />
      <HeroSection />
      <FeatureSection />
      <FeatureGameSection />
      <LetsPlaySection />
    </div>
  );
}
