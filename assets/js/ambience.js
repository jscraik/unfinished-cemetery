/**
 * Unfinished Cemetery - Ambience
 * Starfield + Page transitions + Cursor glow + Scroll reveals
 */

(function() {
  'use strict';

  // ============================================
  // Reduced motion check (early)
  // ============================================
  const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)');
  const reducedMotion = prefersReducedMotion.matches;

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
    const count = Math.min(60, Math.floor((canvas.width * canvas.height) / 20000));
    stars = [];
    
    for (let i = 0; i < count; i++) {
      stars.push({
        x: Math.random() * canvas.width,
        y: Math.random() * canvas.height,
        size: Math.random() * 1.2 + 0.3,
        speed: Math.random() * 0.015 + 0.005,
        opacity: Math.random() * 0.4 + 0.2,
        twinkleSpeed: Math.random() * 0.015 + 0.003,
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
      const opacity = star.opacity * (0.6 + twinkle * 0.4);
      
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
    if (isVisible && !animationId && !reducedMotion) {
      draw();
    } else if (!isVisible && animationId) {
      cancelAnimationFrame(animationId);
      animationId = null;
    }
  });

  // Initialize
  window.addEventListener('resize', resize, { passive: true });
  resize();
  
  if (!reducedMotion) {
    draw();
  } else {
    // Static render once for reduced motion
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    stars.forEach(star => {
      ctx.beginPath();
      ctx.arc(star.x, star.y, star.size, 0, Math.PI * 2);
      ctx.fillStyle = `rgba(230, 237, 243, ${star.opacity * 0.4})`;
      ctx.fill();
    });
  }

  // ============================================
  // Cursor Glow Effect
  // ============================================
  if (!reducedMotion && !window.matchMedia('(pointer: coarse)').matches) {
    const glow = document.createElement('div');
    glow.className = 'cursor-glow';
    document.body.appendChild(glow);
    
    let mouseX = 0;
    let mouseY = 0;
    let glowX = 0;
    let glowY = 0;
    let isMoving = false;
    let moveTimeout = null;
    
    document.addEventListener('mousemove', (e) => {
      mouseX = e.clientX;
      mouseY = e.clientY;
      isMoving = true;
      glow.classList.add('active');
      
      clearTimeout(moveTimeout);
      moveTimeout = setTimeout(() => {
        isMoving = false;
      }, 100);
    }, { passive: true });
    
    document.addEventListener('mouseleave', () => {
      glow.classList.remove('active');
    });
    
    function animateGlow() {
      if (isMoving) {
        glowX += (mouseX - glowX) * 0.08;
        glowY += (mouseY - glowY) * 0.08;
        glow.style.left = glowX + 'px';
        glow.style.top = glowY + 'px';
      }
      requestAnimationFrame(animateGlow);
    }
    animateGlow();
  }

  // ============================================
  // Scroll-Triggered Reveals
  // ============================================
  if (!reducedMotion) {
    const revealElements = document.querySelectorAll('.reveal, .reveal-stagger');
    
    if (revealElements.length > 0) {
      const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            entry.target.classList.add('visible');
            observer.unobserve(entry.target);
          }
        });
      }, {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
      });
      
      revealElements.forEach(el => observer.observe(el));
    }
    
    // Auto-add reveal class to headstone cards if not present
    const headstoneCards = document.querySelectorAll('.headstone-card:not(.reveal)');
    headstoneCards.forEach(card => {
      card.classList.add('reveal');
      const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            entry.target.classList.add('visible');
            observer.unobserve(entry.target);
          }
        });
      }, { threshold: 0.1 });
      observer.observe(card);
    });
  }

  // ============================================
  // Page Transitions
  // ============================================
  const transition = document.getElementById('page-transition');
  
  function fadeToBlack(callback) {
    if (!transition || reducedMotion) {
      callback();
      return;
    }
    
    transition.classList.add('active');
    
    setTimeout(() => {
      callback();
      setTimeout(() => {
        transition.classList.remove('active');
      }, 50);
    }, 300);
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
  // Card hover sound preparation (visual feedback only)
  // ============================================
  const cards = document.querySelectorAll('.headstone-card');
  cards.forEach(card => {
    card.addEventListener('mouseenter', () => {
      card.style.willChange = 'transform, box-shadow';
    });
    card.addEventListener('mouseleave', () => {
      card.style.willChange = 'auto';
    });
  });
})();
