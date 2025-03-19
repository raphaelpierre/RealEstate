document.addEventListener('DOMContentLoaded', function() {
    // Mobile Menu Toggle
    const mobileMenuBtn = document.querySelector('.mobile-menu-btn');
    const navLinks = document.querySelector('.nav-links');
    const ctaButtons = document.querySelector('.cta-buttons');
    
    if (mobileMenuBtn) {
        mobileMenuBtn.addEventListener('click', function() {
            navLinks.classList.toggle('active');
            ctaButtons.classList.toggle('active');
            mobileMenuBtn.classList.toggle('active');
        });
    }
    
    // Pricing Toggle
    const pricingToggle = document.getElementById('pricing-toggle');
    const monthlyPrices = document.querySelectorAll('.monthly-price');
    const yearlyPrices = document.querySelectorAll('.yearly-price');
    
    if (pricingToggle) {
        pricingToggle.addEventListener('change', function() {
            if (this.checked) {
                monthlyPrices.forEach(price => price.style.display = 'none');
                yearlyPrices.forEach(price => price.style.display = 'flex');
            } else {
                monthlyPrices.forEach(price => price.style.display = 'flex');
                yearlyPrices.forEach(price => price.style.display = 'none');
            }
        });
    }
    
    // Benefits Tabs
    const tabBtns = document.querySelectorAll('.tab-btn');
    
    if (tabBtns.length > 0) {
        tabBtns.forEach(btn => {
            btn.addEventListener('click', function() {
                // Remove active class from all buttons
                tabBtns.forEach(b => b.classList.remove('active'));
                
                // Add active class to clicked button
                this.classList.add('active');
                
                // Hide all tab contents
                const tabContents = document.querySelectorAll('.tab-content');
                tabContents.forEach(content => content.classList.remove('active'));
                
                // Show the selected tab content
                const tabId = this.getAttribute('data-tab');
                document.getElementById(`${tabId}-content`).classList.add('active');
            });
        });
    }
    
    // Testimonials Slider
    let currentSlide = 0;
    const testimonialCards = document.querySelectorAll('.testimonial-card');
    const dots = document.querySelectorAll('.dot');
    const prevBtn = document.querySelector('.prev-btn');
    const nextBtn = document.querySelector('.next-btn');
    
    if (testimonialCards.length > 0) {
        // Hide all slides except the first one
        for (let i = 1; i < testimonialCards.length; i++) {
            testimonialCards[i].style.display = 'none';
        }
        
        // Function to show a specific slide
        function showSlide(n) {
            // Hide all slides
            testimonialCards.forEach(card => card.style.display = 'none');
            dots.forEach(dot => dot.classList.remove('active'));
            
            // Show the selected slide
            testimonialCards[n].style.display = 'block';
            dots[n].classList.add('active');
            currentSlide = n;
        }
        
        // Event listeners for dots
        dots.forEach((dot, index) => {
            dot.addEventListener('click', () => showSlide(index));
        });
        
        // Event listeners for prev/next buttons
        if (prevBtn && nextBtn) {
            prevBtn.addEventListener('click', () => {
                let newSlide = currentSlide - 1;
                if (newSlide < 0) newSlide = testimonialCards.length - 1;
                showSlide(newSlide);
            });
            
            nextBtn.addEventListener('click', () => {
                let newSlide = currentSlide + 1;
                if (newSlide >= testimonialCards.length) newSlide = 0;
                showSlide(newSlide);
            });
        }
        
        // Auto-advance slides every 5 seconds
        setInterval(() => {
            let newSlide = currentSlide + 1;
            if (newSlide >= testimonialCards.length) newSlide = 0;
            showSlide(newSlide);
        }, 5000);
    }
    
    // FAQ Accordion
    const faqQuestions = document.querySelectorAll('.faq-question');
    
    if (faqQuestions.length > 0) {
        faqQuestions.forEach(question => {
            question.addEventListener('click', function() {
                const faqItem = this.parentElement;
                faqItem.classList.toggle('active');
            });
        });
    }
    
    // Smooth Scrolling for Anchor Links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function(e) {
            e.preventDefault();
            
            const targetId = this.getAttribute('href');
            if (targetId === '#') return;
            
            const targetElement = document.querySelector(targetId);
            if (targetElement) {
                window.scrollTo({
                    top: targetElement.offsetTop - 80,
                    behavior: 'smooth'
                });
                
                // Close mobile menu if open
                if (navLinks.classList.contains('active')) {
                    navLinks.classList.remove('active');
                    ctaButtons.classList.remove('active');
                    mobileMenuBtn.classList.remove('active');
                }
            }
        });
    });
    
    // Scroll Animation for Elements
    const animateOnScroll = function() {
        const elements = document.querySelectorAll('.feature-card, .benefit-item, .pricing-card, .testimonial-card');
        
        elements.forEach(element => {
            const elementPosition = element.getBoundingClientRect().top;
            const screenPosition = window.innerHeight / 1.3;
            
            if (elementPosition < screenPosition) {
                element.classList.add('animate');
            }
        });
    };
    
    // Add animation class to CSS
    const style = document.createElement('style');
    style.innerHTML = `
        .feature-card, .benefit-item, .pricing-card, .testimonial-card {
            opacity: 0;
            transform: translateY(20px);
            transition: opacity 0.5s ease, transform 0.5s ease;
        }
        
        .feature-card.animate, .benefit-item.animate, .pricing-card.animate, .testimonial-card.animate {
            opacity: 1;
            transform: translateY(0);
        }
    `;
    document.head.appendChild(style);
    
    // Run animation on scroll
    window.addEventListener('scroll', animateOnScroll);
    
    // Run animation on page load
    animateOnScroll();
    
    // Form Validation
    const contactForm = document.querySelector('.contact-form form');
    
    if (contactForm) {
        contactForm.addEventListener('submit', function(e) {
            e.preventDefault();
            
            const nameInput = document.getElementById('name');
            const emailInput = document.getElementById('email');
            const messageInput = document.getElementById('message');
            let isValid = true;
            
            // Simple validation
            if (!nameInput.value.trim()) {
                nameInput.style.borderColor = 'var(--danger-color)';
                isValid = false;
            } else {
                nameInput.style.borderColor = 'var(--border-color)';
            }
            
            if (!emailInput.value.trim() || !isValidEmail(emailInput.value)) {
                emailInput.style.borderColor = 'var(--danger-color)';
                isValid = false;
            } else {
                emailInput.style.borderColor = 'var(--border-color)';
            }
            
            if (!messageInput.value.trim()) {
                messageInput.style.borderColor = 'var(--danger-color)';
                isValid = false;
            } else {
                messageInput.style.borderColor = 'var(--border-color)';
            }
            
            if (isValid) {
                // Simulate form submission
                const submitBtn = contactForm.querySelector('button[type="submit"]');
                const originalText = submitBtn.textContent;
                
                submitBtn.disabled = true;
                submitBtn.textContent = 'Sending...';
                
                setTimeout(() => {
                    // Reset form
                    contactForm.reset();
                    
                    // Show success message
                    const successMessage = document.createElement('div');
                    successMessage.className = 'success-message';
                    successMessage.textContent = 'Your message has been sent successfully!';
                    successMessage.style.color = 'var(--success-color)';
                    successMessage.style.marginTop = '15px';
                    successMessage.style.fontWeight = '500';
                    
                    contactForm.appendChild(successMessage);
                    
                    // Reset button
                    submitBtn.disabled = false;
                    submitBtn.textContent = originalText;
                    
                    // Remove success message after 5 seconds
                    setTimeout(() => {
                        successMessage.remove();
                    }, 5000);
                }, 1500);
            }
        });
    }
    
    // Email validation helper
    function isValidEmail(email) {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return emailRegex.test(email);
    }
    
    // Create images directory and placeholder for app screenshots
    console.log('Note: You need to create an "images" directory and add the following images:');
    console.log('- logo.png (App logo)');
    console.log('- app-showcase.png (Hero image showing the app)');
    console.log('- app-screens.png (Multiple app screens showcase)');
    console.log('- testimonial-1.jpg, testimonial-2.jpg, testimonial-3.jpg (User testimonial profile pictures)');
}); 