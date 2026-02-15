/**
 * Unfinished Cemetery - Ambience
 * Starfield + Page transitions
 */

(function() {
  'use strict';

  // ============================================
  // Starfield
  // ============================================
  const canvas = document.createElement('canvas');
  canvas.id = 'starfield';
  canvas.setAttribute('aria-label', 'Ambient starfield background');
  canvas.setAttribute('role', 'img');
  document.body.insertBefore(canvas, document.body.firstChild);

  const ctx = canvas.getContext('2d');
  let stars = [];
  let animationId = null;
  let isVisible = true;

  function resize() {
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
    initStars();
  }

  function initStars() {
    const count = Math.min(80, Math.floor((canvas.width * canvas.height) / 15000));
    stars = [];
    
    for (let i = 0; i < count; i++) {
      stars.push({
        x: Math.random() * canvas.width,
        y: Math.random() * canvas.height,
        size: Math.random() * 1.5 + 0.5,
        speed: Math.random() * 0.02 + 0.01,
        opacity: Math.random() * 0.5 + 0.3,
        twinkleSpeed: Math.random() * 0.02 + 0.005,
        twinkleOffset: Math.random() * Math.PI * 2
      });
    }
  }

  function draw() {
    if (!isVisible) return;
    
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    
    const time = Date.now() * 0.001;
    
    stars.forEach(star => {
      // Twinkle
      const twinkle = Math.sin(time * star.twinkleSpeed + star.twinkleOffset);
      const opacity = star.opacity * (0.7 + twinkle * 0.3);
      
      // Draw star
      ctx.beginPath();
      ctx.arc(star.x, star.y, star.size, 0, Math.PI * 2);
      ctx.fillStyle = `rgba(230, 237, 243, ${opacity})`;
      ctx.fill();
      
      // Subtle drift
      star.y += star.speed;
      if (star.y > canvas.height) {
        star.y = 0;
        star.x = Math.random() * canvas.width;
      }
    });
    
    animationId = requestAnimationFrame(draw);
  }

  // Visibility handling
  document.addEventListener('visibilitychange', () => {
    isVisible = !document.hidden;
    if (isVisible && !animationId) {
      draw();
    } else if (!isVisible && animationId) {
      cancelAnimationFrame(animationId);
      animationId = null;
    }
  });

  // Initialize
  window.addEventListener('resize', resize, { passive: true });
  resize();
  draw();

  // ============================================
  // Page Transitions
  // ============================================
  const transition = document.getElementById('page-transition');
  
  function fadeToBlack(callback) {
    if (!transition) {
      callback();
      return;
    }
    
    transition.classList.add('active');
    
    setTimeout(() => {
      callback();
      setTimeout(() => {
        transition.classList.remove('active');
      }, 50);
    }, 250);
  }

  // Intercept link clicks for internal navigation
  document.addEventListener('click', (e) => {
    const link = e.target.closest('a');
    if (!link) return;
    
    // Skip external links, anchors, modifier keys
    if (
      link.hostname !== window.location.hostname ||
      link.getAttribute('href')?.startsWith('#') ||
      link.getAttribute('href')?.startsWith('mailto:') ||
      link.getAttribute('href')?.startsWith('tel:') ||
      e.ctrlKey || e.metaKey || e.shiftKey
    ) {
      return;
    }
    
    e.preventDefault();
    const href = link.href;
    
    fadeToBlack(() => {
      window.location.href = href;
    });
  });

  // ============================================
  // Reduced motion check
  // ============================================
  const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)');
  
  if (prefersReducedMotion.matches) {
    // Disable starfield animation
    if (animationId) {
      cancelAnimationFrame(animationId);
      animationId = null;
    }
    // Static render once
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    stars.forEach(star => {
      ctx.beginPath();
      ctx.arc(star.x, star.y, star.size, 0, Math.PI * 2);
      ctx.fillStyle = `rgba(230, 237, 243, ${star.opacity * 0.5})`;
      ctx.fill();
    });
  }
})();
