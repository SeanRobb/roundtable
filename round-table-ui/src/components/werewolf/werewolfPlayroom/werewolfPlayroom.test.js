import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';
import WerewolfPlayroom from './werewolfPlayroom';

describe('<WerewolfPlayroom />', () => {
  test('it should mount', () => {
    render(<WerewolfPlayroom />);
    
    const WerewolfPlayroom = screen.getByTestId('WerewolfPlayroom');

    expect(WerewolfPlayroom).toBeInTheDocument();
  });
});