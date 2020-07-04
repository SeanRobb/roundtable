import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';
import GameOverRoom from './gameOverRoom';

describe('<GameOverRoom />', () => {
  test('it should mount', () => {
    render(<GameOverRoom />);
    
    const GameOverRoom = screen.getByTestId('GameOverRoom');

    expect(GameOverRoom).toBeInTheDocument();
  });
});