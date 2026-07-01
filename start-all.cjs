const { spawn } = require('child_process');
const path = require('path');

console.log('\n🚀 Starting Telegram Clone...\n');

// Start backend server
const backend = spawn('node', ['server/index.cjs'], {
  cwd: __dirname,
  stdio: 'inherit',
  shell: true
});

backend.on('error', (err) => {
  console.error('Failed to start backend:', err);
});

// Start frontend dev server
const frontend = spawn('npm', ['run', 'dev'], {
  cwd: __dirname,
  stdio: 'inherit',
  shell: true
});

frontend.on('error', (err) => {
  console.error('Failed to start frontend:', err);
});

// Handle shutdown
process.on('SIGINT', () => {
  console.log('\n\n🛑 Shutting down...\n');
  backend.kill();
  frontend.kill();
  process.exit();
});

process.on('SIGTERM', () => {
  backend.kill();
  frontend.kill();
  process.exit();
});
