import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';
import CreateGameButton from './createGameButton';

describe('<CreateGameButton />', () => {
  test('it should mount', () => {
    render(<CreateGameButton />);
    
    const CreateGameButton = screen.getByTestId('CreateGameButton');

    expect(CreateGameButton).toBeInTheDocument();
  });
});