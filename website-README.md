# RealEstate App Promotional Website

This is a modern, responsive promotional website for the RealEstate iOS app. The website showcases the app's features, benefits, and pricing plans to attract potential users.

## Features

- Responsive design that works on all devices (mobile, tablet, desktop)
- Modern UI with smooth animations and transitions
- Interactive elements including:
  - Tabbed content sections
  - Pricing toggle (monthly/yearly)
  - Testimonial slider
  - FAQ accordion
  - Contact form with validation
- Optimized for performance and SEO

## File Structure

- `index.html` - Main HTML file containing the website structure
- `styles.css` - CSS styles for the website
- `script.js` - JavaScript for interactive elements
- `images/` - Directory containing all website images

## Images Used

The website uses assets from the RealEstate iOS app to maintain brand consistency:

- `logo.png` - The RealEstate app icon (from AppIcon.appiconset)
- `app-showcase.png` - Banner image from the app (from banner.imageset)
- `app-screens.png` - Banner image used to showcase app screens
- `splash_video.mp4` - Splash video from the app (can be used for video background)
- `testimonial-1.jpg`, `testimonial-2.jpg`, `testimonial-3.jpg` - Placeholder images for testimonials (you should replace these with actual user photos)

## Setup Instructions

1. Clone this repository to your local machine
2. Ensure the `images` directory contains all required images
3. Open `index.html` in your browser to view the website

## Using App Assets for the Website

### Extracting Assets from the App
The assets for this website were extracted from the app's Assets.xcassets folder:

```bash
# Copy app icon to use as logo
cp RealEstate/Assets.xcassets/AppIcon.appiconset/Icon-1024.png images/logo.png

# Copy banner image to use as app showcase
cp RealEstate/Assets.xcassets/banner.imageset/banner.jpeg images/app-showcase.png

# Copy splash video
cp RealEstate/splash_video.mp4 images/
```

### Adding More App Screenshots
To add more app screenshots to the website:

1. Take screenshots of the app running on a device or simulator
2. Save the screenshots in the `images` directory
3. Update the HTML to reference these new images

## Customization

### Colors

The website uses a color scheme defined in CSS variables that match the app's color scheme. You can easily change the colors by modifying the following variables in `styles.css`:

```css
:root {
    --primary-color: #e63946;
    --secondary-color: #1d3557;
    --background-color: #f8f9fa;
    --card-background: #ffffff;
    --text-color: #333333;
    --text-light: #6c757d;
    --border-color: #e9ecef;
    --success-color: #2ecc71;
    --warning-color: #f39c12;
    --danger-color: #e74c3c;
}
```

### Content

To update the website content, simply edit the text in `index.html`. The website is structured in sections, making it easy to locate and modify specific content.

### Pricing

To update the pricing plans, modify the pricing cards in the pricing section of `index.html`. The pricing toggle between monthly and yearly plans is handled by JavaScript in `script.js`.

## Deployment

To deploy this website:

1. Upload all files to your web hosting server
2. Ensure the file structure is maintained
3. Make sure the `images` directory and all required images are included

## Browser Compatibility

This website is compatible with:

- Chrome (latest)
- Firefox (latest)
- Safari (latest)
- Edge (latest)
- Opera (latest)
- Mobile browsers (iOS Safari, Android Chrome)

## Credits

- Font Awesome for icons
- Google Fonts for typography (Poppins)
- Developed for the RealEstate iOS app

## License

This project is licensed under the MIT License - see the LICENSE file for details. 