'use client';
import { Canvas, useFrame } from "@react-three/fiber";
import React, { useRef, useState } from "react";

function Icosahedron({ radius = 3, detail = 0, speed = 0.7, ...props }) {
  // This reference will give us direct access to the mesh
  const meshRef = useRef();
  // Set up state for the hovered and active state
  const [hovered, setHover] = useState(false);
  // Subscribe this component to the render-loop, rotate the mesh every frame
  useFrame((state, delta) => (meshRef.current.rotation.x += delta * speed));
  // Return view, these are regular three.js elements expressed in JSX
  return (
    <mesh
      {...props}
      ref={meshRef}
      onPointerOver={(event) => setHover(true)}
      onPointerOut={(event) => setHover(false)}
    >
      <icosahedronGeometry args={[radius, detail]} />
      <meshPhysicalMaterial
        color={hovered ? "hotpink" : "hotpink"}
        reflectivity={0.8}
        iridescence={0.427}
      />
    </mesh>
  );
}

export default function FeatureSection() {
  return (
    <section id="feature" className="py-14 px-[126px] relative">
      <Canvas style={{ position: 'absolute', width: 'min(550px, 65%)', bottom: 60, height: 300, zIndex: 1 }}>
        <ambientLight intensity={Math.PI / 5} />
        <spotLight
          position={[-7, 0, 12]}
          angle={0.35}
          penumbra={1}
          decay={0}
          intensity={1.2}
        />
        <camera aspect={16 / 10} />
        <pointLight position={[-10, -10, -10]} decay={0} intensity={Math.PI} />
        <Icosahedron
          position={[-1.5, -1, -1]}
          rotation={[0, 3, 3.2]}
          radius={4}
        />
        <Icosahedron
          position={[2, -1.5, 2]}
          rotation={[0, -3.2, 3]}
          scale={0.5}
          speed={1.2}
        />
      </Canvas>
      <h1 className="font-display text-[32px] leading-[40px] text-center text-white">Features of APT-Casino</h1>
      <div className="grid-cols-2 grid py-11 px-20 gap-[60px] mt-14 bg-ruby rounded-3xl z-10 relative" >
        <div id="first-col">
          <div className="">
            <h2 className="text-dark-kiss text-sm font-semibold">Key features</h2>
            <h1 className="text-white my-5 text-[32px] leading-[40px] font-bold">Traditional vs APT-Casino

            </h1>
            <p className="text-white/[0.6] font-medium">Traditional online casinos often lack transparency, and players have to trust the platform's integrity without any verifiable proof of fairness. Issues like rigged games, hidden terms like bonus wager limits, and withdrawal restrictions are common, causing players to lose trust. APT-Casino leverages Aptos and ZetaChain blockchain technology to solve these problems by providing transparent and provably fair gaming experiences.
</p>
          </div>
        </div>
        <div id="second-col" className="flex flex-col gap-5">
          <div className="border-t border-b border-[#E504983D] p-5 flex flex-col gap-3 inner-purple-shadow rounded-xl">
            <h2 className="text-dark-kiss text-sm font-semibold">Transparent and Fair Gaming
</h2>
            <p className="text-white">Provably Fair Gameplay: Utilizing ZetaChain and Aptos fully on-chain randomness module, APT-Casino ensures that all game outcomes are transparent and verifiably fair, giving players confidence in the integrity of the games.

</p>
          </div>
          <div className="border-t border-b border-[#E504983D] p-5 flex flex-col gap-3 inner-purple-shadow rounded-xl">
            <h2 className="text-dark-kiss text-sm font-semibold">Enhanced Security
</h2>
            <p className="text-white">
Security is highly prioritized for newcomers in web3 gambling. APT-Casino utilizes robust security features of ZetaChain Metamask and Aptos Petra wallet infrastructure to protect user assets from unauthorized access. 
</p>
          </div>
          <div className="border-t border-b border-[#E504983D] p-5 flex flex-col gap-3 inner-purple-shadow rounded-xl">
            <h2 className="text-dark-kiss text-sm font-semibold">

Seamless Cross-Chain Integration

</h2>
            <p className="text-white">Managing assets across different blockchains is often hectic at user side. APT-Casino addresses this by offering seamless cross-chain integration, allowing players to transfer and manage assets between Aptos and ZetaChain supported networks effortlessly using Pedra and Metamask.</p>
          </div>
        </div>
      </div>
    </section>
  )
}